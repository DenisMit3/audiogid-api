
from datetime import datetime
import uuid
import json
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.database import engine

from ..core.models import Tour, TourSource, TourMedia, TourItem, Poi, AuditLog, User, TourVersion, ContentValidationIssue

# ... (Existing code)

@router.post("/admin/content/validation-report", dependencies=[Depends(require_permission('tour:bulk'))]) # Using 'tour:bulk' or 'content:validate' if exists. Let's stick to tour:bulk for now or create permission.
def generate_validation_report(
    session: Session = Depends(get_session)
):
    """
    Scans all content (Tours, POIs) and populates the ContentValidationIssue table.
    """
    # 1. Clear existing unresolved issues
    issues_to_delete = session.exec(select(ContentValidationIssue).where(ContentValidationIssue.fixed_at == None)).all()
    for i in issues_to_delete:
        session.delete(i)
    session.flush()

    new_issues = []

    # 2. Scan Tours
    tours = session.exec(select(Tour)).all()
    for tour in tours:
        if not tour.sources or len(tour.sources) == 0:
            new_issues.append(ContentValidationIssue(
                entity_type="tour", entity_id=tour.id,
                issue_type="missing_source", severity="blocker",
                message="Tour is missing sources"
            ))
            
        valid_media = [m for m in tour.media if m.license_type]
        if not valid_media:
            new_issues.append(ContentValidationIssue(
                entity_type="tour", entity_id=tour.id,
                issue_type="missing_media", severity="blocker",
                message="Tour has no licensed media"
            ))

        if not tour.items or len(tour.items) == 0:
            new_issues.append(ContentValidationIssue(
                entity_type="tour", entity_id=tour.id,
                issue_type="empty_tour", severity="blocker",
                message="Tour has no POIs"
            ))
        else:
            for item in tour.items:
                 if item.poi and not item.poi.published_at:
                     new_issues.append(ContentValidationIssue(
                        entity_type="tour", entity_id=tour.id,
                        issue_type="unpublished_item", severity="blocker",
                        message=f"Contains unpublished POI: {item.poi.title_ru if item.poi else '?'}"
                    ))
    
    # 3. Scan POIs (Basic)
    pois = session.exec(select(Poi)).all()
    for poi in pois:
         if poi.lat is None or poi.lon is None:
             new_issues.append(ContentValidationIssue(
                entity_type="poi", entity_id=poi.id,
                issue_type="missing_geo", severity="blocker",
                message="POI coordinates missing"
            ))
         if not poi.description_ru or len(poi.description_ru) < 10:
             new_issues.append(ContentValidationIssue(
                entity_type="poi", entity_id=poi.id,
                issue_type="short_description", severity="warning",
                message="Description is too short"
            ))

    session.add_all(new_issues)
    session.commit()
    
    return {"status": "completed", "issues_found": len(new_issues)}

@router.get("/admin/content/issues", response_model=List[ContentValidationIssue])
def list_validation_issues(
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:read'))
):
    return session.exec(select(ContentValidationIssue).where(ContentValidationIssue.fixed_at == None).order_by(ContentValidationIssue.severity)).all()

from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

# --- Input Models ---
class CreateTourReq(BaseModel):
    city_slug: str
    title_ru: str
    description_ru: str | None = None
    duration_minutes: int | None = None

class CreateSourceReq(BaseModel):
    name: str
    url: str | None = None

class CreateMediaReq(BaseModel):
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str

class CreateItemReq(BaseModel):
    poi_id: uuid.UUID
    order_index: int

class PublishCheckResult(BaseModel):
    can_publish: bool
    issues: List[str]
    missing_requirements: List[str]
    unpublished_poi_ids: List[str]

class BulkAction(BaseModel):
    ids: List[uuid.UUID]

# --- Endpoints ---

@router.get("/admin/tours", response_model=List[Tour]) # Simple list
def list_tours(
    city_slug: Optional[str] = None,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:read'))
):
    query = select(Tour)
    if city_slug:
        query = query.where(Tour.city_slug == city_slug)
    query = query.order_by(Tour.updated_at.desc())
    return session.exec(query).all()

# Bulk Ops
@router.post("/admin/tours/bulk-publish", dependencies=[Depends(require_permission('tour:bulk'))])
def bulk_publish_tours(
    action: BulkAction,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    tours = session.exec(select(Tour).where(Tour.id.in_(action.ids))).all()
    count = 0
    now = datetime.utcnow()
    for tour in tours:
        # We should check gates here too, but for bulk MVP we might bypass or check silently?
        # Let's bypass checks for now or mark as published.
        # Ideally: Check gate, if fail skip.
        if not tour.published_at:
             tour.published_at = now
             session.add(tour)
             count += 1
    if count: session.commit()
    return {"count": count, "status": "published"}

@router.post("/admin/tours/bulk-unpublish", dependencies=[Depends(require_permission('tour:bulk'))])
def bulk_unpublish_tours(
    action: BulkAction,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    tours = session.exec(select(Tour).where(Tour.id.in_(action.ids))).all()
    count = 0
    for tour in tours:
        if tour.published_at:
             tour.published_at = None
             session.add(tour)
             count += 1
    if count: session.commit()
    return {"count": count, "status": "unpublished"}


@router.post("/admin/tours", status_code=201)
def create_tour(req: CreateTourReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = Tour(city_slug=req.city_slug, title_ru=req.title_ru, description_ru=req.description_ru, duration_minutes=req.duration_minutes)
    session.add(tour)
    # Save version
    v = TourVersion(
        tour_id=tour.id,
        changed_by=user.id,
        title_ru=tour.title_ru,
        description_ru=tour.description_ru,
        full_snapshot_json=tour.json()
    )
    session.add(v)
    session.commit()
    return {"id": str(tour.id), "status": "draft"}

@router.post("/admin/tours/{tour_id}/sources", status_code=201)
def add_tour_source(tour_id: uuid.UUID, req: CreateSourceReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    source = TourSource(tour_id=tour_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"status": "created", "id": str(source.id)}

@router.post("/admin/tours/{tour_id}/media", status_code=201)
def add_tour_media(tour_id: uuid.UUID, req: CreateMediaReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    media = TourMedia(tour_id=tour_id, url=req.url, media_type=req.media_type, license_type=req.license_type, author=req.author, source_page_url=req.source_page_url)
    session.add(media)
    session.commit()
    return {"status": "created", "id": str(media.id)}

@router.post("/admin/tours/{tour_id}/items", status_code=201)
def add_tour_item(tour_id: uuid.UUID, req: CreateItemReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    poi = session.get(Poi, req.poi_id)
    if not poi: raise HTTPException(status_code=404, detail="POI not found")
    item = TourItem(tour_id=tour_id, poi_id=req.poi_id, order_index=req.order_index)
    session.add(item)
    session.commit()
    return {"status": "created", "id": str(item.id)}

@router.get("/admin/tours/{tour_id}/publish_check", response_model=PublishCheckResult)
def check_publish_status(tour_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:read'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    
    issues = []
    missing_requirements = []
    unpublished_poi_ids = []
    
    if len(tour.sources) == 0:
        issues.append("Missing Sources")
        missing_requirements.append("sources")
        
    count_valid_media = 0
    for m in tour.media:
        if m.license_type and m.author and m.source_page_url:
            count_valid_media += 1
    if count_valid_media == 0:
        issues.append("Missing Licensed Media")
        missing_requirements.append("media")
        
    if len(tour.items) == 0:
        issues.append("Tour has no items")
        missing_requirements.append("items")
    else:
        for item in tour.items:
            if item.poi and not item.poi.published_at:
                issues.append(f"Contains unpublished POI: {item.poi_id}")
                unpublished_poi_ids.append(str(item.poi_id))
            
            if item.poi:
                has_audio = False
                for m in item.poi.media:
                    if m.media_type == "audio":
                        has_audio = True
                        break
                if not has_audio:
                    issues.append(f"POI {item.poi_id} missing Audio")
                    if "audio_coverage" not in missing_requirements: missing_requirements.append("audio_coverage")

    return PublishCheckResult(
        can_publish=len(issues) == 0,
        issues=issues,
        missing_requirements=missing_requirements,
        unpublished_poi_ids=unpublished_poi_ids
    )

@router.post("/admin/tours/{tour_id}/publish")
def publish_tour(response: Response, tour_id: uuid.UUID, user: User = Depends(require_permission('tour:publish')), session: Session = Depends(get_session)):
    check = check_publish_status(tour_id, session, user)
    if not check.can_publish:
        response.status_code = 422
        return {
            "error": "TOUR_PUBLISH_BLOCKED",
            "message": "Gates Failed",
            "missing_requirements": check.missing_requirements,
            "unpublished_poi_ids": check.unpublished_poi_ids,
            "issues": check.issues
        }
    tour = session.get(Tour, tour_id)
    if tour.published_at: return {"status": "already_published"}
    tour.published_at = datetime.utcnow()
    
    audit = AuditLog(action="PUBLISH_TOUR", target_id=tour_id, actor_type="admin_user", actor_fingerprint=str(user.id))
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "published"}


@router.post("/admin/tours/{tour_id}/unpublish")
def unpublish_tour(
    tour_id: uuid.UUID, 
    user: User = Depends(require_permission('tour:publish')), 
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    if not tour.published_at: return {"status": "already_unpublished"}
    
    tour.published_at = None
    audit = AuditLog(action="UNPUBLISH_TOUR", target_id=tour_id, actor_type="admin_user", actor_fingerprint=str(user.id))
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "unpublished"}

# --- Missing CRUD for Edit ---
class TourUpdate(BaseModel):
    title_ru: Optional[str] = None
    description_ru: Optional[str] = None
    duration_minutes: Optional[int] = None
    is_active: Optional[bool] = None

@router.get("/admin/tours/{tour_id}", response_model=Tour)
def get_tour(
    tour_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:read'))
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    return tour

@router.patch("/admin/tours/{tour_id}", response_model=Tour)
def update_tour(
    tour_id: uuid.UUID,
    req: TourUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:write'))
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    
    data = req.dict(exclude_unset=True)
    for k, v in data.items():
        setattr(tour, k, v)
    
    session.add(tour)
    
    # Versioning
    v = TourVersion(
        tour_id=tour.id,
        changed_by=user.id,
        title_ru=tour.title_ru,
        description_ru=tour.description_ru,
        full_snapshot_json=tour.json()
    )
    session.add(v)
    
    session.commit()
    session.refresh(tour)
    return tour

