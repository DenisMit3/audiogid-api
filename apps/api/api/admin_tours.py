from datetime import datetime
import uuid
import hashlib
from fastapi import APIRouter, Depends, Query, HTTPException, Header, Response
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import List

from ..core.database import engine
from ..core.models import Tour, TourSource, TourMedia, TourItem, Poi, AuditLog
from ..core.config import config

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

def verify_admin_token(x_admin_token: str = Header(...)):
    if x_admin_token != config.ADMIN_API_TOKEN:
        raise HTTPException(status_code=403, detail="Invalid Admin Token")
    return x_admin_token

def get_token_fingerprint(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()

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

@router.post("/admin/tours", status_code=201, dependencies=[Depends(verify_admin_token)])
def create_tour(
    req: CreateTourReq, 
    session: Session = Depends(get_session)
):
    tour = Tour(
        city_slug=req.city_slug,
        title_ru=req.title_ru,
        description_ru=req.description_ru,
        duration_minutes=req.duration_minutes
    )
    session.add(tour)
    session.commit()
    return {"id": str(tour.id), "status": "draft"}

@router.post("/admin/tours/{tour_id}/sources", status_code=201, dependencies=[Depends(verify_admin_token)])
def add_tour_source(
    tour_id: uuid.UUID,
    req: CreateSourceReq,
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
        
    source = TourSource(tour_id=tour_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"status": "created", "id": str(source.id)}

@router.post("/admin/tours/{tour_id}/media", status_code=201, dependencies=[Depends(verify_admin_token)])
def add_tour_media(
    tour_id: uuid.UUID,
    req: CreateMediaReq,
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
        
    media = TourMedia(
        tour_id=tour_id,
        url=req.url,
        media_type=req.media_type,
        license_type=req.license_type,
        author=req.author,
        source_page_url=req.source_page_url
    )
    session.add(media)
    session.commit()
    return {"status": "created", "id": str(media.id)}

@router.post("/admin/tours/{tour_id}/items", status_code=201, dependencies=[Depends(verify_admin_token)])
def add_tour_item(
    tour_id: uuid.UUID,
    req: CreateItemReq,
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
    
    poi = session.get(Poi, req.poi_id)
    if not poi: raise HTTPException(status_code=404, detail="POI not found")
    
    item = TourItem(
        tour_id=tour_id,
        poi_id=req.poi_id,
        order_index=req.order_index
    )
    session.add(item)
    session.commit()
    return {"status": "created", "id": str(item.id)}

@router.get("/admin/tours/{tour_id}/publish_check", dependencies=[Depends(verify_admin_token)], response_model=PublishCheckResult)
def check_publish_status(
    tour_id: uuid.UUID,
    session: Session = Depends(get_session)
):
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
            # Check recursive publish
            if item.poi and not item.poi.published_at:
                issues.append(f"Contains unpublished POI: {item.poi_id}")
                unpublished_poi_ids.append(str(item.poi_id))

    return PublishCheckResult(
        can_publish=len(issues) == 0,
        issues=issues,
        missing_requirements=missing_requirements,
        unpublished_poi_ids=unpublished_poi_ids
    )

@router.post("/admin/tours/{tour_id}/publish")
def publish_tour(
    response: Response,
    tour_id: uuid.UUID,
    token: str = Depends(verify_admin_token),
    session: Session = Depends(get_session)
):
    check = check_publish_status(tour_id, session)
    if not check.can_publish:
        # Machine readable error 422
        response.status_code = 422
        return {
            "error": "TOUR_PUBLISH_BLOCKED",
            "message": "Gates Failed",
            "missing_requirements": check.missing_requirements,
            "unpublished_poi_ids": check.unpublished_poi_ids
        }
        
    tour = session.get(Tour, tour_id)
    if tour.published_at:
        return {"status": "already_published"}
        
    tour.published_at = datetime.utcnow()
    
    fingerprint = get_token_fingerprint(token)
    audit = AuditLog(
        action="PUBLISH_TOUR", 
        target_id=tour_id,
        actor_type="admin_token",
        actor_fingerprint=fingerprint
    )
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "published"}

@router.post("/admin/tours/{tour_id}/unpublish")
def unpublish_tour(
    tour_id: uuid.UUID,
    token: str = Depends(verify_admin_token),
    session: Session = Depends(get_session)
):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(status_code=404, detail="Tour not found")
        
    if not tour.published_at: return {"status": "already_unpublished"}
        
    tour.published_at = None
    
    fingerprint = get_token_fingerprint(token)
    audit = AuditLog(
        action="UNPUBLISH_TOUR", 
        target_id=tour_id,
        actor_type="admin_token",
        actor_fingerprint=fingerprint
    )
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "unpublished"}
