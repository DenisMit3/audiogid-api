"""
Admin Itineraries API - просмотр пользовательских маршрутов (readonly)
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
from pydantic import BaseModel
from datetime import datetime
import uuid

from ..core.models import Itinerary, ItineraryItem, Poi, User, City
from ..auth.deps import get_session, require_permission

router = APIRouter()

# --- Schemas ---

class ItineraryItemRead(BaseModel):
    id: uuid.UUID
    poi_id: uuid.UUID
    poi_title: Optional[str]
    poi_lat: Optional[float]
    poi_lon: Optional[float]
    order_index: int

class ItineraryRead(BaseModel):
    id: uuid.UUID
    user_id: Optional[uuid.UUID]
    device_anon_id: Optional[str]
    title: str
    city_slug: str
    city_name: Optional[str]
    created_at: datetime
    updated_at: datetime
    items_count: int

class ItineraryDetailRead(BaseModel):
    id: uuid.UUID
    user_id: Optional[uuid.UUID]
    device_anon_id: Optional[str]
    title: str
    city_slug: str
    city_name: Optional[str]
    created_at: datetime
    updated_at: datetime
    items: List[ItineraryItemRead]

class ItineraryListResponse(BaseModel):
    items: List[ItineraryRead]
    total: int

class ItineraryStats(BaseModel):
    total_itineraries: int
    total_items: int
    by_city: dict
    recent_count: int  # last 7 days

# --- Endpoints ---

@router.get("/admin/itineraries", response_model=ItineraryListResponse)
def list_itineraries(
    city_slug: Optional[str] = None,
    device_anon_id: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 50,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Список пользовательских маршрутов"""
    query = select(Itinerary)
    
    if city_slug:
        query = query.where(Itinerary.city_slug == city_slug)
    if device_anon_id:
        query = query.where(Itinerary.device_anon_id == device_anon_id)
    if search:
        query = query.where(Itinerary.title.ilike(f"%{search}%"))
    
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    query = query.order_by(Itinerary.updated_at.desc())
    query = query.offset((page - 1) * per_page).limit(per_page)
    itineraries = session.exec(query).all()
    
    # Enrich with city names and item counts
    result = []
    for it in itineraries:
        city = session.exec(select(City).where(City.slug == it.city_slug)).first()
        items_count = session.exec(
            select(func.count()).select_from(ItineraryItem).where(ItineraryItem.itinerary_id == it.id)
        ).one()
        
        result.append(ItineraryRead(
            id=it.id,
            user_id=it.user_id,
            device_anon_id=it.device_anon_id,
            title=it.title,
            city_slug=it.city_slug,
            city_name=city.name_ru if city else None,
            created_at=it.created_at,
            updated_at=it.updated_at,
            items_count=items_count
        ))
    
    return {"items": result, "total": total}

@router.get("/admin/itineraries/stats", response_model=ItineraryStats)
def get_itineraries_stats(
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Статистика по пользовательским маршрутам"""
    from datetime import timedelta
    
    total_itineraries = session.exec(select(func.count()).select_from(Itinerary)).one()
    total_items = session.exec(select(func.count()).select_from(ItineraryItem)).one()
    
    # By city
    city_stats = session.exec(
        select(Itinerary.city_slug, func.count(Itinerary.id).label('count'))
        .group_by(Itinerary.city_slug)
    ).all()
    by_city = {r[0]: r[1] for r in city_stats}
    
    # Recent (last 7 days)
    week_ago = datetime.utcnow() - timedelta(days=7)
    recent_count = session.exec(
        select(func.count()).select_from(Itinerary).where(Itinerary.created_at >= week_ago)
    ).one()
    
    return ItineraryStats(
        total_itineraries=total_itineraries,
        total_items=total_items,
        by_city=by_city,
        recent_count=recent_count
    )

@router.get("/admin/itineraries/{itinerary_id}", response_model=ItineraryDetailRead)
def get_itinerary(
    itinerary_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Получить детали маршрута с POI"""
    itinerary = session.get(Itinerary, itinerary_id)
    if not itinerary:
        raise HTTPException(404, "Маршрут не найден")
    
    city = session.exec(select(City).where(City.slug == itinerary.city_slug)).first()
    
    # Get items with POI info
    items_query = select(ItineraryItem).where(
        ItineraryItem.itinerary_id == itinerary_id
    ).order_by(ItineraryItem.order_index)
    items = session.exec(items_query).all()
    
    items_read = []
    for item in items:
        poi = session.get(Poi, item.poi_id)
        items_read.append(ItineraryItemRead(
            id=item.id,
            poi_id=item.poi_id,
            poi_title=poi.title_ru if poi else None,
            poi_lat=poi.lat if poi else None,
            poi_lon=poi.lon if poi else None,
            order_index=item.order_index
        ))
    
    return ItineraryDetailRead(
        id=itinerary.id,
        user_id=itinerary.user_id,
        device_anon_id=itinerary.device_anon_id,
        title=itinerary.title,
        city_slug=itinerary.city_slug,
        city_name=city.name_ru if city else None,
        created_at=itinerary.created_at,
        updated_at=itinerary.updated_at,
        items=items_read
    )
