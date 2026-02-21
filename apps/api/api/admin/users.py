
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, text
from datetime import datetime, timedelta
from typing import List, Optional
from pydantic import BaseModel
import uuid

from ..core.database import engine
from ..core.models import User, UserIdentity, Role, AuditLog, BlacklistedToken
from ..auth.deps import get_session, require_permission

router = APIRouter()

class UserRead(BaseModel):
    id: uuid.UUID
    role: str
    is_active: bool
    created_at: datetime
    identities_count: int
    last_login: Optional[datetime] = None
    phone: Optional[str] = None # Representative identity

class UserUpdate(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None

@router.get("/admin/users", response_model=List[UserRead])
def list_users(
    offset: int = 0,
    limit: int = 50,
    role: Optional[str] = None,
    search: Optional[str] = None,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    query = select(User).distinct()
    if role:
        query = query.where(User.role == role)
    if search:
        try:
            uid = uuid.UUID(search)
            query = query.where(User.id == uid)
        except ValueError:
            # Search by phone/email in UserIdentity
            query = query.join(UserIdentity).where(UserIdentity.provider_id.ilike(f"%{search}%"))
            
    query = query.offset(offset).limit(limit).order_by(User.created_at.desc())
    users = session.exec(query).all()
    
    res = []
    for u in users:
        # Load identities
        idents = session.exec(select(UserIdentity).where(UserIdentity.user_id == u.id)).all()
        last_login = max([i.last_login for i in idents if i.last_login] or [u.created_at])
        phone = idents[0].provider_id if idents else None
        
        res.append(UserRead(
            id=u.id,
            role=u.role,
            is_active=u.is_active,
            created_at=u.created_at,
            identities_count=len(idents),
            last_login=last_login,
            phone=phone
        ))
    return res

@router.get("/admin/users/{user_id}", response_model=UserRead)
def get_user(
    user_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(404, "User not found")
        
    idents = session.exec(select(UserIdentity).where(UserIdentity.user_id == user.id)).all()
    last_login = max([i.last_login for i in idents if i.last_login] or [user.created_at])
    phone = idents[0].provider_id if idents else None
    
    return UserRead(
        id=user.id,
        role=user.role,
        is_active=user.is_active,
        created_at=user.created_at,
        identities_count=len(idents),
        last_login=last_login,
        phone=phone
    )

@router.patch("/admin/users/{user_id}")
def update_user(
    user_id: uuid.UUID,
    params: UserUpdate,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(404, "User not found")
        
    if params.role is not None:
        user.role = params.role
        # Also try to sync with Role table if it exists
        # Find Role by slug
        role_obj = session.exec(select(Role).where(Role.slug == params.role)).first()
        if role_obj:
            user.role_id = role_obj.id
            
    if params.is_active is not None:
        user.is_active = params.is_active
        
    session.add(user)
    
    # Audit log
    audit = AuditLog(
        action="update_user",
        target_id=user_id,
        actor_type="admin",
        actor_fingerprint=str(admin.id),
        trace_id=f"update keys: {params.dict(exclude_unset=True)}"
    )
    session.add(audit)
    
    session.commit()
    return {"status": "updated", "user": {"id": str(user.id), "role": user.role, "is_active": user.is_active}}

@router.post("/admin/users/{user_id}/revoke")
def revoke_user_sessions(
    user_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    """
    Отзыв всех сессий пользователя.
    Добавляет все активные токены пользователя в blacklist.
    """
    from ..auth.service import blacklist_token, create_access_token
    from datetime import timedelta
    
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    
    # Получаем все identity пользователя для логирования
    idents = session.exec(select(UserIdentity).where(UserIdentity.user_id == user_id)).all()
    
    # Добавляем запись в blacklist с user_id
    # Это позволит проверять при валидации токена, был ли он выпущен до revoke
    # Создаем специальную запись-маркер для user_id
    revoke_marker = BlacklistedToken(
        token_hash=f"revoke_all_{user_id}_{datetime.utcnow().timestamp()}",
        expires_at=datetime.utcnow() + timedelta(days=7),  # Срок жизни refresh token
        user_id=user_id
    )
    session.add(revoke_marker)
    
    # Обновляем user - устанавливаем флаг принудительной реаутентификации
    # Для этого можно использовать поле или просто полагаться на blacklist
    
    # Audit log
    audit = AuditLog(
        action="revoke_sessions",
        target_id=user_id,
        actor_type="admin",
        actor_fingerprint=str(admin.id),
        trace_id=f"identities_count: {len(idents)}"
    )
    session.add(audit)
    session.commit()
    
    return {
        "status": "revoked", 
        "message": f"Все сессии пользователя отозваны. Затронуто {len(idents)} identity.",
        "identities_affected": len(idents)
    }

@router.post("/admin/users/{user_id}/block")
def block_user(
    user_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    """
    Блокировка пользователя.
    Деактивирует аккаунт и отзывает все сессии.
    """
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    
    if user.id == admin.id:
        raise HTTPException(400, "Нельзя заблокировать самого себя")
    
    # Деактивируем пользователя
    user.is_active = False
    session.add(user)
    
    # Отзываем сессии (добавляем маркер в blacklist)
    revoke_marker = BlacklistedToken(
        token_hash=f"blocked_{user_id}_{datetime.utcnow().timestamp()}",
        expires_at=datetime.utcnow() + timedelta(days=365),  # Блокировка на год
        user_id=user_id
    )
    session.add(revoke_marker)
    
    # Audit log
    audit = AuditLog(
        action="block_user",
        target_id=user_id,
        actor_type="admin",
        actor_fingerprint=str(admin.id)
    )
    session.add(audit)
    session.commit()
    
    return {"status": "blocked", "message": "Пользователь заблокирован"}

@router.post("/admin/users/{user_id}/unblock")
def unblock_user(
    user_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('users:manage'))
):
    """
    Разблокировка пользователя.
    """
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    
    user.is_active = True
    session.add(user)
    
    # Audit log
    audit = AuditLog(
        action="unblock_user",
        target_id=user_id,
        actor_type="admin",
        actor_fingerprint=str(admin.id)
    )
    session.add(audit)
    session.commit()
    
    return {"status": "unblocked", "message": "Пользователь разблокирован"}
