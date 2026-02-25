
from typing import List, Optional, Any
from datetime import datetime, timedelta
import uuid
import json

from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlmodel import Session, select, func, or_
from pydantic import BaseModel

from ..core.models import (
    Tour, TourBase, TourSource, TourMedia, TourItem, Poi, AuditLog, User, TourVersion, 
    ContentValidationIssue, AppEvent, PoiBase
)
from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

# --- SCHEMAS ---

class CreateTourReq(BaseModel):
    city_slug: str
    title_ru: str
    title_en: Optional[str] = None
    description_ru: Optional[str] = None
    description_en: Optional[str] = None
    duration_minutes: Optional[int] = None
    tour_type: str = "walking"
    difficulty: str = "easy"
    cover_image: Optional[str] = None

class TourUpdate(BaseModel):
    title_ru: Optional[str] = None
    title_en: Optional[str] = None
    description_ru: Optional[str] = None
    description_en: Optional[str] = None
    duration_minutes: Optional[int] = None
    city_slug: Optional[str] = None
    tour_type: Optional[str] = None
    difficulty: Optional[str] = None
    cover_image: Optional[str] = None

class TourRead(TourBase):
    id: uuid.UUID
    is_deleted: bool
    
class TourItemRead(BaseModel):
    id: uuid.UUID
    poi_id: Optional[uuid.UUID]
    order_index: int
    poi_title: Optional[str] # enriched
    poi_lat: Optional[float]
    poi_lon: Optional[float]
    poi_published_at: Optional[str] # enriched - POI publication status
    transition_text_ru: Optional[str]
    transition_audio_url: Optional[str]
    duration_seconds: Optional[int]

class TourDetailResponse(BaseModel):
    tour: TourRead
    items: List[TourItemRead]
    sources: List[Any]
    media: List[Any]
    can_publish: bool
    publish_issues: List[str]
    unpublished_poi_ids: List[str]

class CreateSourceReq(BaseModel):
    name: str
    url: Optional[str] = None

class CreateMediaReq(BaseModel):
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str

class CreateItemReq(BaseModel):
    poi_id: uuid.UUID
    order_index: int
    transition_text_ru: Optional[str] = None
    transition_audio_url: Optional[str] = None
    duration_seconds: Optional[int] = None

class TourItemUpdate(BaseModel):
    transition_text_ru: Optional[str] = None
    transition_audio_url: Optional[str] = None
    duration_seconds: Optional[int] = None
    order_index: Optional[int] = None

class ReorderItemsReq(BaseModel):
    item_ids: List[uuid.UUID]

class PublishCheckResult(BaseModel):
    can_publish: bool
    issues: List[str]
    missing_requirements: List[str]
    unpublished_poi_ids: List[str]

class BulkAction(BaseModel):
    ids: List[uuid.UUID]

class TourListResponse(BaseModel):
    items: List[TourRead]
    total: int
    page: int
    per_page: int
    pages: int

# --- ENDPOINTS ---

@router.get("/admin/tours", response_model=TourListResponse)
def list_tours(
    city_slug: Optional[str] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:read'))
):
    query = select(Tour).where(Tour.is_deleted == False)
    
    if city_slug:
        query = query.where(Tour.city_slug == city_slug)
    
    if status == "published":
        query = query.where(Tour.published_at.isnot(None))
    elif status == "draft":
        query = query.where(Tour.published_at.is_(None))
        
    if search:
        query = query.where(Tour.title_ru.ilike(f"%{search}%"))
        
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    query = query.order_by(Tour.updated_at.desc())
    query = query.offset((page-1)*per_page).limit(per_page)
    items = session.exec(query).all()
    
    return {
        "items": items,
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }

@router.post("/admin/tours", status_code=201, response_model=TourRead)
def create_tour(req: CreateTourReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = Tour(
        city_slug=req.city_slug, 
        title_ru=req.title_ru, 
        description_ru=req.description_ru, 
        duration_minutes=req.duration_minutes,
        title_en=req.title_en,
        description_en=req.description_en,
        tour_type=req.tour_type,
        difficulty=req.difficulty,
        cover_image=req.cover_image
    )
    session.add(tour)
    
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

@router.get("/admin/tours/{tour_id}", response_model=TourDetailResponse)
def get_tour(
    tour_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:read'))
):
    tour = session.get(Tour, tour_id)
    if not tour or tour.is_deleted: raise HTTPException(404, "Tour not found")
    
    # Enrich items with POI titles
    items_read = []
    for item in tour.items:
        poi_title = item.poi.title_ru if item.poi else "Deleted POI"
        items_read.append({
            "id": item.id,
            "poi_id": item.poi_id,
            "order_index": item.order_index,
            "poi_title": poi_title,
            "poi_lat": item.poi.lat if item.poi else None,
            "poi_lon": item.poi.lon if item.poi else None,
            "poi_published_at": item.poi.published_at.isoformat() if item.poi and item.poi.published_at else None,
            "transition_text_ru": item.transition_text_ru,
            "transition_audio_url": item.transition_audio_url,
            "duration_seconds": item.duration_seconds
        })
    items_read.sort(key=lambda x: x['order_index'])
    
    # Check Publish Status
    check = check_publish_status(tour_id, session, user)
    
    return {
        "tour": tour,
        "items": items_read,
        "sources": tour.sources,
        "media": tour.media,
        "can_publish": check.can_publish,
        "publish_issues": check.issues,
        "unpublished_poi_ids": check.unpublished_poi_ids
    }

@router.patch("/admin/tours/{tour_id}", response_model=TourRead)
def update_tour(
    tour_id: uuid.UUID,
    req: TourUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:write'))
):
    tour = session.get(Tour, tour_id)
    if not tour or tour.is_deleted: raise HTTPException(404, "Tour not found")
    
    data = req.dict(exclude_unset=True)
    for k, v in data.items():
        setattr(tour, k, v)
    
    session.add(tour)
    
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

@router.delete("/admin/tours/{tour_id}")
def delete_tour(
    tour_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:delete'))
):
    tour = session.get(Tour, tour_id)
    if not tour or tour.is_deleted: raise HTTPException(404)
    
    tour.is_deleted = True
    tour.deleted_at = datetime.utcnow()
    tour.published_at = None
    
    session.add(tour)
    session.add(AuditLog(action="DELETE_TOUR", target_id=tour_id, actor_fingerprint=str(user.id)))
    session.commit()
    return {"status": "deleted"}

# --- Sub-resources Operations ---

@router.post("/admin/tours/{tour_id}/sources", status_code=201)
def add_tour_source(tour_id: uuid.UUID, req: CreateSourceReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404)
    source = TourSource(tour_id=tour_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"id": source.id}

@router.delete("/admin/tours/{tour_id}/sources/{source_id}")
def delete_tour_source(tour_id: uuid.UUID, source_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    source = session.get(TourSource, source_id)
    if not source or source.tour_id != tour_id: raise HTTPException(404)
    session.delete(source)
    session.commit()
    return {"status": "deleted"}

@router.post("/admin/tours/{tour_id}/media", status_code=201)
def add_tour_media(tour_id: uuid.UUID, req: CreateMediaReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404)
    media = TourMedia(tour_id=tour_id, **req.dict())
    session.add(media)
    session.commit()
    return {"id": media.id}

@router.delete("/admin/tours/{tour_id}/media/{media_id}")
def delete_tour_media(tour_id: uuid.UUID, media_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    media = session.get(TourMedia, media_id)
    if not media or media.tour_id != tour_id: raise HTTPException(404)
    session.delete(media)
    session.commit()
    return {"status": "deleted"}

@router.patch("/admin/tours/{tour_id}/items/{item_id}", response_model=TourItemRead)
def update_tour_item(
    tour_id: uuid.UUID, 
    item_id: uuid.UUID,
    req: TourItemUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('tour:write'))
):
    item = session.get(TourItem, item_id)
    if not item or item.tour_id != tour_id: raise HTTPException(404, "Item not found")
    
    data = req.dict(exclude_unset=True)
    for k, v in data.items():
        setattr(item, k, v)
        
    session.add(item)
    session.commit()
    session.refresh(item)
    
    # Return read model
    poi_title = item.poi.title_ru if item.poi else "Deleted POI"
    return {
        "id": item.id,
        "poi_id": item.poi_id,
        "order_index": item.order_index,
        "poi_title": poi_title,
        "poi_lat": item.poi.lat if item.poi else None,
        "poi_lon": item.poi.lon if item.poi else None,
        "poi_published_at": item.poi.published_at.isoformat() if item.poi and item.poi.published_at else None,
        "transition_text_ru": item.transition_text_ru,
        "transition_audio_url": item.transition_audio_url,
        "duration_seconds": item.duration_seconds
    }

@router.post("/admin/tours/{tour_id}/items", status_code=201)
def add_tour_item(tour_id: uuid.UUID, req: CreateItemReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404)
    poi = session.get(Poi, req.poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    
    item = TourItem(
        tour_id=tour_id, 
        poi_id=req.poi_id, 
        order_index=req.order_index,
        transition_text_ru=req.transition_text_ru,
        transition_audio_url=req.transition_audio_url,
        duration_seconds=req.duration_seconds
    )
    session.add(item)
    session.commit()
    return {"id": item.id}

@router.delete("/admin/tours/{tour_id}/items/{item_id}")
def delete_tour_item(tour_id: uuid.UUID, item_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    item = session.get(TourItem, item_id)
    if not item or item.tour_id != tour_id: raise HTTPException(404)
    session.delete(item)
    session.commit()
    return {"status": "deleted"}

@router.patch("/admin/tours/{tour_id}/items")
def reorder_tour_items(tour_id: uuid.UUID, req: ReorderItemsReq, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404)
    
    # Verify all items belong to tour
    current_items = {item.id: item for item in tour.items}
    for item_id in req.item_ids:
        if item_id not in current_items:
            raise HTTPException(400, f"Item {item_id} does not belong to this tour")
            
    # Update order
    for idx, item_id in enumerate(req.item_ids):
        current_items[item_id].order_index = idx
        session.add(current_items[item_id])
        
    session.commit()
    return {"status": "reordered"}

@router.post("/admin/tours/{tour_id}/duplicate")
def duplicate_tour(tour_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:write'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404)
    
    # 1. Clone Tour
    new_tour = Tour(
        city_slug=tour.city_slug,
        title_ru=f"{tour.title_ru} (Copy)",
        title_en=tour.title_en,
        description_ru=tour.description_ru,
        description_en=tour.description_en,
        duration_minutes=tour.duration_minutes,
        distance_km=tour.distance_km,
        tour_type=tour.tour_type,
        difficulty=tour.difficulty,
        cover_image=tour.cover_image
    )
    session.add(new_tour)
    session.flush() # get ID
    
    # 2. Clone Sources
    for s in tour.sources:
        session.add(TourSource(tour_id=new_tour.id, name=s.name, url=s.url))
        
    # 3. Clone Media
    for m in tour.media:
        session.add(TourMedia(tour_id=new_tour.id, url=m.url, media_type=m.media_type, license_type=m.license_type, author=m.author, source_page_url=m.source_page_url))
        
    # 4. Clone Items
    for i in tour.items:
        session.add(TourItem(tour_id=new_tour.id, poi_id=i.poi_id, order_index=i.order_index))
        
    session.commit()
    return {"id": new_tour.id, "title": new_tour.title_ru}

# --- Validation & Publishing ---

@router.get("/admin/tours/{tour_id}/publish_check", response_model=PublishCheckResult)
def check_publish_status(tour_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('tour:read'))):
    tour = session.get(Tour, tour_id)
    if not tour: raise HTTPException(404, detail="Tour not found")
    
    issues = []
    missing_requirements = []
    unpublished_poi_ids = []
    
    # if len(tour.sources) == 0:
    #     issues.append("Missing Sources")
    #     missing_requirements.append("sources")
        
    count_valid_media = 0
    for m in tour.media:
        if m.license_type and m.author: # Simplified check
            count_valid_media += 1
    # if count_valid_media == 0:
    #     issues.append("Missing Licensed Media")
    #     missing_requirements.append("media")
        
    if len(tour.items) == 0:
        issues.append("Tour has no items")
        missing_requirements.append("items")
    else:
        for item in tour.items:
            if item.poi and not item.poi.published_at:
                issues.append(f"Contains unpublished POI: {item.poi.title_ru}")
                unpublished_poi_ids.append(str(item.poi_id))
            if item.poi and item.poi.is_deleted:
                issues.append(f"Contains deleted POI")
            
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
            "issues": check.issues
        }
    tour = session.get(Tour, tour_id)
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
    if not tour: raise HTTPException(status_code=404)
    
    tour.published_at = None
    audit = AuditLog(action="UNPUBLISH_TOUR", target_id=tour_id, actor_type="admin_user", actor_fingerprint=str(user.id))
    session.add(audit)
    session.add(tour)
    session.commit()
    return {"status": "unpublished"}

@router.post("/admin/content/validation-report", dependencies=[Depends(require_permission('tour:bulk'))])
def generate_validation_report(
    session: Session = Depends(get_session)
):
    # Clear existing
    session.exec(select(ContentValidationIssue).where(ContentValidationIssue.fixed_at == None)).all()
    # Simple logic to clear old issues would be delete where fixed_at is None? 
    # Or just delete all pending and recreate.
    # For now, let's just return a stub or simple count
    return {"status": "not_implemented_fully"}

@router.get("/admin/content/issues")
def list_validation_issues(session: Session = Depends(get_session)):
    return []

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
