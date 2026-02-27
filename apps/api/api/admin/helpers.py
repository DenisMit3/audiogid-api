"""
Admin Helpers API - управление вспомогательными точками (туалеты, кафе, питьевая вода)
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
from pydantic import BaseModel
import uuid

from ..core.models import HelperPlace, User, City
from ..auth.deps import get_session, get_current_admin, require_permission

router = APIRouter()

# --- Schemas ---

class HelperCreate(BaseModel):
    city_slug: str
    type: str  # toilet, cafe, drinking_water, atm, pharmacy, other
    lat: float
    lon: float
    name_ru: Optional[str] = None
    name_en: Optional[str] = None
    osm_id: Optional[str] = None
    address: Optional[str] = None
    opening_hours: Optional[str] = None

class HelperUpdate(BaseModel):
    type: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    name_ru: Optional[str] = None
    name_en: Optional[str] = None
    osm_id: Optional[str] = None
    address: Optional[str] = None
    opening_hours: Optional[str] = None

class HelperRead(BaseModel):
    id: uuid.UUID
    city_slug: str
    type: str
    lat: float
    lon: float
    name_ru: Optional[str]
    name_en: Optional[str]
    osm_id: Optional[str]
    address: Optional[str]
    opening_hours: Optional[str]

class HelperListResponse(BaseModel):
    items: List[HelperRead]
    total: int

# Helper types
HELPER_TYPES = ['toilet', 'cafe', 'drinking_water', 'atm', 'pharmacy', 'bench', 'viewpoint', 'other']

# --- CRUD ---

@router.get("/admin/helpers", response_model=HelperListResponse)
def list_helpers(
    city_slug: Optional[str] = None,
    type: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 100,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Список вспомогательных точек"""
    query = select(HelperPlace)
    
    if city_slug:
        query = query.where(HelperPlace.city_slug == city_slug)
    if type:
        query = query.where(HelperPlace.type == type)
    if search:
        query = query.where(
            (HelperPlace.name_ru.ilike(f"%{search}%")) |
            (HelperPlace.address.ilike(f"%{search}%"))
        )
    
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    query = query.order_by(HelperPlace.city_slug, HelperPlace.type)
    query = query.offset((page - 1) * per_page).limit(per_page)
    items = session.exec(query).all()
    
    return {
        "items": [HelperRead(
            id=h.id,
            city_slug=h.city_slug,
            type=h.type,
            lat=h.lat,
            lon=h.lon,
            name_ru=h.name_ru,
            name_en=getattr(h, 'name_en', None),
            osm_id=h.osm_id,
            address=getattr(h, 'address', None),
            opening_hours=getattr(h, 'opening_hours', None)
        ) for h in items],
        "total": total
    }

@router.post("/admin/helpers", response_model=HelperRead, status_code=201)
def create_helper(
    data: HelperCreate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:write'))
):
    """Создать вспомогательную точку"""
    # Validate city
    city = session.exec(select(City).where(City.slug == data.city_slug)).first()
    if not city:
        raise HTTPException(400, f"Город '{data.city_slug}' не найден")
    
    # Validate type
    if data.type not in HELPER_TYPES:
        raise HTTPException(400, f"Неверный тип. Допустимые: {', '.join(HELPER_TYPES)}")
    
    helper = HelperPlace(
        id=uuid.uuid4(),
        city_slug=data.city_slug,
        type=data.type,
        lat=data.lat,
        lon=data.lon,
        name_ru=data.name_ru,
        osm_id=data.osm_id
    )
    
    # Set optional fields if model supports them
    if hasattr(helper, 'name_en'):
        helper.name_en = data.name_en
    if hasattr(helper, 'address'):
        helper.address = data.address
    if hasattr(helper, 'opening_hours'):
        helper.opening_hours = data.opening_hours
    
    session.add(helper)
    session.commit()
    session.refresh(helper)
    
    return HelperRead(
        id=helper.id,
        city_slug=helper.city_slug,
        type=helper.type,
        lat=helper.lat,
        lon=helper.lon,
        name_ru=helper.name_ru,
        name_en=getattr(helper, 'name_en', None),
        osm_id=helper.osm_id,
        address=getattr(helper, 'address', None),
        opening_hours=getattr(helper, 'opening_hours', None)
    )

@router.get("/admin/helpers/{helper_id}", response_model=HelperRead)
def get_helper(
    helper_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Получить точку по ID"""
    helper = session.get(HelperPlace, helper_id)
    if not helper:
        raise HTTPException(404, "Точка не найдена")
    
    return HelperRead(
        id=helper.id,
        city_slug=helper.city_slug,
        type=helper.type,
        lat=helper.lat,
        lon=helper.lon,
        name_ru=helper.name_ru,
        name_en=getattr(helper, 'name_en', None),
        osm_id=helper.osm_id,
        address=getattr(helper, 'address', None),
        opening_hours=getattr(helper, 'opening_hours', None)
    )

@router.patch("/admin/helpers/{helper_id}", response_model=HelperRead)
def update_helper(
    helper_id: uuid.UUID,
    data: HelperUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:write'))
):
    """Обновить точку"""
    helper = session.get(HelperPlace, helper_id)
    if not helper:
        raise HTTPException(404, "Точка не найдена")
    
    if data.type and data.type not in HELPER_TYPES:
        raise HTTPException(400, f"Неверный тип. Допустимые: {', '.join(HELPER_TYPES)}")
    
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if hasattr(helper, key):
            setattr(helper, key, value)
    
    session.add(helper)
    session.commit()
    session.refresh(helper)
    
    return HelperRead(
        id=helper.id,
        city_slug=helper.city_slug,
        type=helper.type,
        lat=helper.lat,
        lon=helper.lon,
        name_ru=helper.name_ru,
        name_en=getattr(helper, 'name_en', None),
        osm_id=helper.osm_id,
        address=getattr(helper, 'address', None),
        opening_hours=getattr(helper, 'opening_hours', None)
    )

@router.delete("/admin/helpers/{helper_id}")
def delete_helper(
    helper_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:write'))
):
    """Удалить точку"""
    helper = session.get(HelperPlace, helper_id)
    if not helper:
        raise HTTPException(404, "Точка не найдена")
    
    session.delete(helper)
    session.commit()
    return {"status": "deleted"}

@router.get("/admin/helpers/types/list")
def list_helper_types(
    user: User = Depends(require_permission('content:read'))
):
    """Список доступных типов точек"""
    return {
        "types": [
            {"value": "toilet", "label": "Туалет"},
            {"value": "cafe", "label": "Кафе"},
            {"value": "drinking_water", "label": "Питьевая вода"},
            {"value": "atm", "label": "Банкомат"},
            {"value": "pharmacy", "label": "Аптека"},
            {"value": "bench", "label": "Скамейка"},
            {"value": "viewpoint", "label": "Смотровая площадка"},
            {"value": "other", "label": "Другое"}
        ]
    }

@router.get("/admin/helpers/stats")
def get_helpers_stats(
    city_slug: Optional[str] = None,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('content:read'))
):
    """Статистика по типам точек"""
    query = select(HelperPlace.type, func.count(HelperPlace.id).label('count'))
    
    if city_slug:
        query = query.where(HelperPlace.city_slug == city_slug)
    
    query = query.group_by(HelperPlace.type)
    results = session.exec(query).all()
    
    stats = {r[0]: r[1] for r in results}
    total = sum(stats.values())
    
    return {
        "total": total,
        "by_type": stats
    }
