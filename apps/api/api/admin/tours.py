from datetime import datetime
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.database import engine
from ..core.models import Tour, TourSource, TourMedia, TourItem, Poi, AuditLog, User
from ..auth.deps import get_current_admin, get_session

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

# --- Endpoints ---

@router.get("/admin/tours", response_model=List[Tour]) # Simple list
def list_tours(
    city_slug: Optional[str] = None,
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin)
):
    query = select(Tour)
    if city_slug:
        query = query.where(Tour.city_slug == city_slug)
    query = query.order_by(Tour.updated_at.desc())
    return session.exec(query).all()


@router.post("/admin/tours", status_code=201)
def create_tour(req: CreateTourReq, session: Session = Depends(get_session), admin: User = Depends(get_current_admin)):
    tour = Tour(city_slug=req.city_slug, title_ru=req.title_ru, description_ru=req.description_ru, duration_minutes=req.duration_minutes)
    session.add(tour)
    session.commit()
    return {"id": str(tour.id), "status": "draft"}

@router.post("/admin/tours/{tour_id}/sources", status_code=201)
def add_tour_source(tour_id: uuid.UUID, req: CreateSourceReq, session: Session = Depends(get_session), admin: User = Depends(get_current_admin)):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    source = TourSource(tour_id=tour_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"status": "created", "id": str(source.id)}

@router.post("/admin/tours/{tour_id}/media", status_code=201)
def add_tour_media(tour_id: uuid.UUID, req: CreateMediaReq, session: Session = Depends(get_session), admin: User = Depends(get_current_admin)):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    media = TourMedia(tour_id=tour_id, url=req.url, media_type=req.media_type, license_type=req.license_type, author=req.author, source_page_url=req.source_page_url)
    session.add(media)
    session.commit()
    return {"status": "created", "id": str(media.id)}

@router.post("/admin/tours/{tour_id}/items", status_code=201)
def add_tour_item(tour_id: uuid.UUID, req: CreateItemReq, session: Session = Depends(get_session), admin: User = Depends(get_current_admin)):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    poi = session.get(Poi, req.poi_id)
    if not poi: raise HTTPException(status_code=404, detail="POI not found")
    item = TourItem(tour_id=tour_id, poi_id=req.poi_id, order_index=req.order_index)
    session.add(item)
    session.commit()
    return {"status": "created", "id": str(item.id)}

@router.get("/admin/tours/{tour_id}/publish_check", response_model=PublishCheckResult)
def check_publish_status(tour_id: uuid.UUID, session: Session = Depends(get_session), admin: User = Depends(get_current_admin)):
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
def publish_tour(response: Response, tour_id: uuid.UUID, admin: User = Depends(get_current_admin), session: Session = Depends(get_session)):
    check = check_publish_status(tour_id, session, admin)
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
    
    audit = AuditLog(action="PUBLISH_TOUR", target_id=tour_id, actor_type="admin_user", actor_fingerprint=str(admin.id))
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "published"}

@router.post("/admin/tours/{tour_id}/unpublish")
def unpublish_tour(
    tour_id: uuid.UUID, 
    admin: User = Depends(get_current_admin), 
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    if not tour.published_at: return {"status": "already_unpublished"}
    
    tour.published_at = None
    audit = AuditLog(action="UNPUBLISH_TOUR", target_id=tour_id, actor_type="admin_user", actor_fingerprint=str(admin.id))
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "unpublished"}
