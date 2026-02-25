
from typing import List, Optional
from uuid import UUID
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, or_
from pydantic import BaseModel

from ..core.models import City, CityBase, AuditLog, AppEvent, User, Poi, Tour
from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

# --- SCHEMAS ---

class CityCreate(CityBase):
    pass

class CityUpdate(BaseModel):
    slug: Optional[str] = None
    name_ru: Optional[str] = None
    name_en: Optional[str] = None
    description_ru: Optional[str] = None
    description_en: Optional[str] = None
    cover_image: Optional[str] = None
    bounds_lat_min: Optional[float] = None
    bounds_lat_max: Optional[float] = None
    bounds_lon_min: Optional[float] = None
    bounds_lon_max: Optional[float] = None
    default_zoom: Optional[float] = None
    timezone: Optional[str] = None
    is_active: Optional[bool] = None
    osm_relation_id: Optional[int] = None

class CityRead(CityBase):
    id: UUID
    updated_at: datetime
    poi_count: int = 0
    tour_count: int = 0

class CityListResponse(BaseModel):
    items: List[CityRead]
    total: int
    page: int
    per_page: int
    pages: int

# --- ENDPOINTS ---

@router.get("/admin/cities", response_model=CityListResponse)
def list_cities(
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('city:read'))
):
    query = select(City)
    
    if search:
        query = query.where(or_(
            City.name_ru.ilike(f"%{search}%"),
            City.slug.ilike(f"%{search}%")
        ))
    
    # Count total
    total_query = select(func.count()).select_from(query.subquery())
    total = session.exec(total_query).one()
    
    # Pagination
    query = query.order_by(City.name_ru)
    query = query.offset((page - 1) * per_page).limit(per_page)
    cities = session.exec(query).all()
    
    # Enriched response with counts
    items = []
    for city in cities:
        # Count POIs and Tours for this city using proper queries
        poi_count = session.exec(
            select(func.count()).select_from(Poi).where(Poi.city_slug == city.slug)
        ).one()
        tour_count = session.exec(
            select(func.count()).select_from(Tour).where(Tour.city_slug == city.slug)
        ).one()
        
        items.append(CityRead(
            **city.dict(),
            poi_count=poi_count,
            tour_count=tour_count
        ))

    return {
        "items": items,
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }

@router.post("/admin/cities", response_model=CityRead)
def create_city(
    city_in: CityCreate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('city:write'))
):
    # Check slug uniqueness
    existing = session.exec(select(City).where(City.slug == city_in.slug)).first()
    if existing:
        raise HTTPException(400, "City with this slug already exists")

    db_city = City.from_orm(city_in)
    db_city.id = uuid.uuid4()
    
    session.add(db_city)
    
    session.add(AppEvent(event_type="city_created", user_id=user.id, payload_json=f'{{"slug": "{db_city.slug}"}}'))
    session.add(AuditLog(action="CREATE_CITY", target_id=db_city.id, actor_fingerprint=str(user.id)))
    
    session.commit()
    session.refresh(db_city)
    
    return CityRead(**db_city.dict(), poi_count=0, tour_count=0)

@router.get("/admin/cities/{city_id}", response_model=CityRead)
def get_city(
    city_id: UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('city:read'))
):
    city = session.get(City, city_id)
    if not city: raise HTTPException(404, "City not found")
    
    poi_count = session.exec(
        select(func.count()).select_from(Poi).where(Poi.city_slug == city.slug)
    ).one()
    tour_count = session.exec(
        select(func.count()).select_from(Tour).where(Tour.city_slug == city.slug)
    ).one()
    
    return CityRead(**city.dict(), poi_count=poi_count, tour_count=tour_count)

@router.patch("/admin/cities/{city_id}", response_model=CityRead)
def update_city(
    city_id: UUID,
    data: CityUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('city:write'))
):
    city = session.get(City, city_id)
    if not city: raise HTTPException(404, "City not found")
    
    city_data = data.dict(exclude_unset=True)
    
    # If slug is changing, check uniqueness
    if "slug" in city_data and city_data["slug"] != city.slug:
         existing = session.exec(select(City).where(City.slug == city_data["slug"])).first()
         if existing: raise HTTPException(400, "City with this slug already exists")
    
    for key, value in city_data.items():
        setattr(city, key, value)
    
    city.updated_at = datetime.utcnow()
    
    session.add(city)
    session.add(AuditLog(action="UPDATE_CITY", target_id=city.id, actor_fingerprint=str(user.id)))
    session.commit()
    session.refresh(city)
    
    poi_count = session.exec(
        select(func.count()).select_from(Poi).where(Poi.city_slug == city.slug)
    ).one()
    tour_count = session.exec(
        select(func.count()).select_from(Tour).where(Tour.city_slug == city.slug)
    ).one()
    
    return CityRead(**city.dict(), poi_count=poi_count, tour_count=tour_count)

@router.delete("/admin/cities/{city_id}")
def delete_city(
    city_id: UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('city:delete'))
):
    city = session.get(City, city_id)
    if not city: raise HTTPException(404, "City not found")
    
    # Check for dependent content
    if city.pois and len(city.pois) > 0:
        raise HTTPException(400, f"Cannot delete city with {len(city.pois)} POIs. Please delete or reassign them first.")
    
    if city.tours and len(city.tours) > 0:
        raise HTTPException(400, f"Cannot delete city with {len(city.tours)} Tours. Please delete or reassign them first.")

    session.delete(city)
    session.add(AuditLog(action="DELETE_CITY", target_id=city_id, actor_fingerprint=str(user.id)))
    session.commit()
    
    return {"status": "deleted"}
