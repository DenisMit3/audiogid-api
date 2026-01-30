
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, or_
from typing import List, Optional
from pydantic import BaseModel
import logging

from ..core.database import engine
from ..core.models import Poi, Tour, TourItem, PoiSource, PoiMedia, User, Entitlement

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
            
        # Check Sources (Require >= 2)
        sources_count = session.exec(select(func.count(PoiSource.id)).where(PoiSource.poi_id == p.id)).one()
        if sources_count < 2:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_source",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_sources",
                severity="blocker", # Promoted to blocker
                message=f"Not enough sources ({sources_count}). Minimum 2 required."
            ))

        # Check Media/Narrations (Require >= 1 Licensed Media)
        # Assuming we check 'license_type' in PoiMedia or similar.
        # For now, just checking count >= 1 is a good start, but let's try to be specific if model allows.
        # Checking simply if any media exists for now.
        media_count = session.exec(select(func.count(PoiMedia.id)).where(PoiMedia.poi_id == p.id)).one()
        if media_count < 1:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_media",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="no_media",
                severity="blocker",
                message="No media files attached. At least 1 licensed media required."
            ))

        # Preview Content (Audio + Bullets)
        if not p.preview_audio_url:
            issues.append(ValidationIssue(
                id=f"poi_{p.id}_preview_audio_check", # Renamed ID to avoid conflict
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_preview_audio",
                severity="blocker", # Promoted
                message="Preview audio (10-25s) is required."
            ))
            
        # Check Preview Bullets (>= 3)
        # Assuming preview_bullets is a JSON list or similar in DB model
        bullets = p.preview_bullets or []
        if len(bullets) < 3:
            issues.append(ValidationIssue(
                id=f"poi_{p.id}_preview_bullets_check",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_preview_bullets",
                severity="blocker",
                message=f"Preview bullets ({len(bullets)}) are too few. Minimum 3 required."
            ))

        # Transcript (Description as proxy)
        if not p.description_ru or len(p.description_ru) < 100:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_transcript",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="short_transcript",
                severity="warning",
                message="Transcript/Description is too short (<100 chars)."
            ))

        # Pricing/Entitlement Check
        # Check if there is an Entitlement referencing this POI or the City it belongs to.
        entitlement_exists = session.exec(select(Entitlement).where(
            or_(
                Entitlement.ref == str(p.id),
                Entitlement.ref == p.city_slug
            )
        )).first()

        if not entitlement_exists:
             issues.append(ValidationIssue(
                id=f"poi_{p.id}_pricing",
                entity_id=str(p.id),
                entity_type="poi",
                issue_type="missing_pricing",
                severity="warning",
                message="No pricing/entitlement found for this POI or its City."
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
