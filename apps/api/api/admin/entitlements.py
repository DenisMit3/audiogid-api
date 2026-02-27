"""
Admin Entitlements API - управление продуктами и правами доступа
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
from pydantic import BaseModel
from datetime import datetime
import uuid

from ..core.models import Entitlement, EntitlementGrant, User, City, Tour
from ..auth.deps import get_session, get_current_admin, require_permission

router = APIRouter()

# --- Schemas ---

class EntitlementCreate(BaseModel):
    slug: str
    scope: str  # city | tour
    ref: str    # city_slug или tour_id
    title_ru: str
    price_amount: float = 0.0
    price_currency: str = "RUB"
    is_active: bool = True

class EntitlementUpdate(BaseModel):
    title_ru: Optional[str] = None
    price_amount: Optional[float] = None
    price_currency: Optional[str] = None
    is_active: Optional[bool] = None

class EntitlementRead(BaseModel):
    id: uuid.UUID
    slug: str
    scope: str
    ref: str
    title_ru: str
    price_amount: float
    price_currency: str
    is_active: bool
    ref_title: Optional[str] = None  # Название города/тура

class EntitlementListResponse(BaseModel):
    items: List[EntitlementRead]
    total: int

class GrantCreate(BaseModel):
    device_anon_id: Optional[str] = None
    user_id: Optional[uuid.UUID] = None
    source: str = "promo"  # promo | system | manual
    expires_at: Optional[datetime] = None

class GrantRead(BaseModel):
    id: uuid.UUID
    device_anon_id: Optional[str]
    user_id: Optional[uuid.UUID]
    entitlement_id: uuid.UUID
    entitlement_slug: str
    entitlement_title: str
    source: str
    source_ref: str
    granted_at: datetime
    revoked_at: Optional[datetime]

class GrantListResponse(BaseModel):
    items: List[GrantRead]
    total: int

# --- Entitlements CRUD ---

@router.get("/admin/entitlements", response_model=EntitlementListResponse)
def list_entitlements(
    scope: Optional[str] = None,
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:read'))
):
    """Список всех продуктов/прав"""
    query = select(Entitlement)
    
    if scope:
        query = query.where(Entitlement.scope == scope)
    if is_active is not None:
        query = query.where(Entitlement.is_active == is_active)
    if search:
        query = query.where(Entitlement.title_ru.ilike(f"%{search}%"))
    
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    items = session.exec(query.order_by(Entitlement.slug)).all()
    
    # Enrich with ref titles
    result = []
    for e in items:
        ref_title = None
        if e.scope == "city":
            city = session.exec(select(City).where(City.slug == e.ref)).first()
            if city:
                ref_title = city.name_ru
        elif e.scope == "tour":
            try:
                tour = session.get(Tour, uuid.UUID(e.ref))
                if tour:
                    ref_title = tour.title_ru
            except ValueError:
                pass
        
        result.append(EntitlementRead(
            id=e.id,
            slug=e.slug,
            scope=e.scope,
            ref=e.ref,
            title_ru=e.title_ru,
            price_amount=e.price_amount,
            price_currency=e.price_currency,
            is_active=e.is_active,
            ref_title=ref_title
        ))
    
    return {"items": result, "total": total}

@router.post("/admin/entitlements", response_model=EntitlementRead, status_code=201)
def create_entitlement(
    data: EntitlementCreate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:write'))
):
    """Создать новый продукт"""
    # Check slug uniqueness
    existing = session.exec(select(Entitlement).where(Entitlement.slug == data.slug)).first()
    if existing:
        raise HTTPException(400, f"Продукт с slug '{data.slug}' уже существует")
    
    # Validate ref
    if data.scope == "city":
        city = session.exec(select(City).where(City.slug == data.ref)).first()
        if not city:
            raise HTTPException(400, f"Город '{data.ref}' не найден")
    elif data.scope == "tour":
        try:
            tour = session.get(Tour, uuid.UUID(data.ref))
            if not tour:
                raise HTTPException(400, f"Тур '{data.ref}' не найден")
        except ValueError:
            raise HTTPException(400, "Неверный формат UUID тура")
    
    entitlement = Entitlement(
        id=uuid.uuid4(),
        slug=data.slug,
        scope=data.scope,
        ref=data.ref,
        title_ru=data.title_ru,
        price_amount=data.price_amount,
        price_currency=data.price_currency,
        is_active=data.is_active
    )
    session.add(entitlement)
    session.commit()
    session.refresh(entitlement)
    
    return EntitlementRead(
        id=entitlement.id,
        slug=entitlement.slug,
        scope=entitlement.scope,
        ref=entitlement.ref,
        title_ru=entitlement.title_ru,
        price_amount=entitlement.price_amount,
        price_currency=entitlement.price_currency,
        is_active=entitlement.is_active
    )

@router.get("/admin/entitlements/{entitlement_id}", response_model=EntitlementRead)
def get_entitlement(
    entitlement_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:read'))
):
    """Получить продукт по ID"""
    entitlement = session.get(Entitlement, entitlement_id)
    if not entitlement:
        raise HTTPException(404, "Продукт не найден")
    
    return EntitlementRead(
        id=entitlement.id,
        slug=entitlement.slug,
        scope=entitlement.scope,
        ref=entitlement.ref,
        title_ru=entitlement.title_ru,
        price_amount=entitlement.price_amount,
        price_currency=entitlement.price_currency,
        is_active=entitlement.is_active
    )

@router.patch("/admin/entitlements/{entitlement_id}", response_model=EntitlementRead)
def update_entitlement(
    entitlement_id: uuid.UUID,
    data: EntitlementUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:write'))
):
    """Обновить продукт"""
    entitlement = session.get(Entitlement, entitlement_id)
    if not entitlement:
        raise HTTPException(404, "Продукт не найден")
    
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(entitlement, key, value)
    
    session.add(entitlement)
    session.commit()
    session.refresh(entitlement)
    
    return EntitlementRead(
        id=entitlement.id,
        slug=entitlement.slug,
        scope=entitlement.scope,
        ref=entitlement.ref,
        title_ru=entitlement.title_ru,
        price_amount=entitlement.price_amount,
        price_currency=entitlement.price_currency,
        is_active=entitlement.is_active
    )

@router.delete("/admin/entitlements/{entitlement_id}")
def delete_entitlement(
    entitlement_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:write'))
):
    """Удалить продукт"""
    entitlement = session.get(Entitlement, entitlement_id)
    if not entitlement:
        raise HTTPException(404, "Продукт не найден")
    
    # Check if there are active grants
    grants_count = session.exec(
        select(func.count()).select_from(EntitlementGrant).where(
            EntitlementGrant.entitlement_id == entitlement_id,
            EntitlementGrant.revoked_at.is_(None)
        )
    ).one()
    
    if grants_count > 0:
        raise HTTPException(400, f"Невозможно удалить: есть {grants_count} активных прав")
    
    session.delete(entitlement)
    session.commit()
    return {"status": "deleted"}

# --- Grants ---

@router.get("/admin/entitlement-grants", response_model=GrantListResponse)
def list_grants(
    entitlement_id: Optional[uuid.UUID] = None,
    device_anon_id: Optional[str] = None,
    source: Optional[str] = None,
    active_only: bool = True,
    page: int = 1,
    per_page: int = 50,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:read'))
):
    """Список выданных прав"""
    query = select(EntitlementGrant)
    
    if entitlement_id:
        query = query.where(EntitlementGrant.entitlement_id == entitlement_id)
    if device_anon_id:
        query = query.where(EntitlementGrant.device_anon_id == device_anon_id)
    if source:
        query = query.where(EntitlementGrant.source == source)
    if active_only:
        query = query.where(EntitlementGrant.revoked_at.is_(None))
    
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    query = query.order_by(EntitlementGrant.granted_at.desc())
    query = query.offset((page - 1) * per_page).limit(per_page)
    grants = session.exec(query).all()
    
    # Enrich with entitlement info
    result = []
    for g in grants:
        entitlement = session.get(Entitlement, g.entitlement_id)
        result.append(GrantRead(
            id=g.id,
            device_anon_id=g.device_anon_id,
            user_id=g.user_id,
            entitlement_id=g.entitlement_id,
            entitlement_slug=entitlement.slug if entitlement else "unknown",
            entitlement_title=entitlement.title_ru if entitlement else "Unknown",
            source=g.source,
            source_ref=g.source_ref,
            granted_at=g.granted_at,
            revoked_at=g.revoked_at
        ))
    
    return {"items": result, "total": total}

@router.post("/admin/entitlements/{entitlement_id}/grant", response_model=GrantRead, status_code=201)
def grant_entitlement(
    entitlement_id: uuid.UUID,
    data: GrantCreate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:write'))
):
    """Выдать право доступа"""
    entitlement = session.get(Entitlement, entitlement_id)
    if not entitlement:
        raise HTTPException(404, "Продукт не найден")
    
    if not data.device_anon_id and not data.user_id:
        raise HTTPException(400, "Укажите device_anon_id или user_id")
    
    # Generate unique source_ref
    source_ref = f"{data.source}_{uuid.uuid4().hex[:8]}"
    
    grant = EntitlementGrant(
        id=uuid.uuid4(),
        device_anon_id=data.device_anon_id,
        user_id=data.user_id,
        entitlement_id=entitlement_id,
        source=data.source,
        source_ref=source_ref,
        granted_at=datetime.utcnow()
    )
    session.add(grant)
    session.commit()
    session.refresh(grant)
    
    return GrantRead(
        id=grant.id,
        device_anon_id=grant.device_anon_id,
        user_id=grant.user_id,
        entitlement_id=grant.entitlement_id,
        entitlement_slug=entitlement.slug,
        entitlement_title=entitlement.title_ru,
        source=grant.source,
        source_ref=grant.source_ref,
        granted_at=grant.granted_at,
        revoked_at=grant.revoked_at
    )

@router.delete("/admin/entitlement-grants/{grant_id}")
def revoke_grant(
    grant_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('billing:write'))
):
    """Отозвать право доступа"""
    grant = session.get(EntitlementGrant, grant_id)
    if not grant:
        raise HTTPException(404, "Право не найдено")
    
    if grant.revoked_at:
        raise HTTPException(400, "Право уже отозвано")
    
    grant.revoked_at = datetime.utcnow()
    session.add(grant)
    session.commit()
    
    return {"status": "revoked"}
