
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, or_
from typing import List, Optional
from pydantic import BaseModel
import logging

from ..core.database import engine
from ..core.models import Poi, Tour, TourItem, PoiSource, PoiMedia, User
from ..auth.deps import get_session, require_permission

router = APIRouter()
logger = logging.getLogger(__name__)

class ValidationIssue(BaseModel):
    id: str # Unique ID for keying
    entity_id: str
    entity_type: str # 'poi' or 'tour'
    issue_type: str 
    severity: str # 'blocker', 'warning', 'info'
    message: str

@router.get("/admin/content/issues", response_model=List[ValidationIssue])
def get_validation_issues(
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read')) # Assuming content permission
):
    issues = []
    
    # --- POI Validation ---
    pois = session.exec(select(Poi)).all()
    for p in pois:
        # Blocker: Minimum Title
        if not p.title_ru or len(p.title_ru) < 3:
            issues.append(ValidationIssue(
                id=f"poi_{p.id}_title",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_title",
                severity="blocker",
                message="Title (RU) is missing or too short."
            ))
            
        # Blocker: Long Description for Publish
        if not p.description_ru or len(p.description_ru) < 50:
            issues.append(ValidationIssue(
                id=f"poi_{p.id}_desc",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="short_description",
                severity="warning",
                message="Description (RU) is missing or shorter than 50 chars."
            ))
            
        # Warning: No Category
        if not p.category:
            issues.append(ValidationIssue(
                id=f"poi_{p.id}_category",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_category",
                severity="warning",
                message="Category is not selected."
            ))
            
        # Warning: No Cover Image
        if not p.cover_image:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_cover",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_cover",
                severity="warning", 
                message="Cover image is missing."
            ))
            
        # Check Sources
        sources_count = session.exec(select(func.count(PoiSource.id)).where(PoiSource.poi_id == p.id)).one()
        if sources_count == 0:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_source",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_sources",
                severity="warning",
                message="No sources cited."
            ))

        # Check Media/Narrations (Basic check if any media exists)
        # Assuming Narrations are stored in PoiMedia with specific type or specialized table?
        # Current model check:
        # Narrations are separate table? Or PoiMedia?
        # Let's check for ANY media
        media_count = session.exec(select(func.count(PoiMedia.id)).where(PoiMedia.poi_id == p.id)).one()
        if media_count == 0:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_media",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="no_media",
                severity="info",
                message="No media files attached."
            ))
            
    # --- Tour Validation ---
    tours = session.exec(select(Tour)).all()
    for t in tours:
        if not t.title_ru:
            issues.append(ValidationIssue(
                id=f"tour_{t.id}_title",
                entity_id=str(t.id),
                entity_type="tour",
                issue_type="missing_title",
                severity="blocker",
                message="Title (RU) is missing."
            ))
            
        if not t.cover_image:
            issues.append(ValidationIssue(
                id=f"tour_{t.id}_cover",
                entity_id=str(t.id),
                entity_type="tour",
                issue_type="missing_cover",
                severity="warning",
                message="Cover image is missing."
            ))
            
        # Check items
        items_count = session.exec(select(func.count(TourItem.id)).where(TourItem.tour_id == t.id)).one()
        if items_count < 2:
             issues.append(ValidationIssue(
                id=f"tour_{t.id}_items",
                entity_id=str(t.id),
                entity_type="tour",
                issue_type="not_enough_stops",
                severity="blocker",
                message=f"Tour has too few stops ({items_count}). Minimum 2 required."
            ))

    return issues

@router.post("/admin/content/validation-report")
def generate_validation_report(
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:edit'))
):
    # For now, this just returns success, triggering frontend re-fetch
    # In future, this could save a report record to DB.
    return {"status": "generated", "timestamp": "now"}
