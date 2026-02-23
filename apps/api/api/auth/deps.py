
from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlmodel import Session, select
from ..core.database import engine
from ..core.models import User, Permission, RolePermission
from ..core.config import config
from . import service  # Import service for blacklist check
import uuid
from jose import jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token", auto_error=False)

def get_session() -> Generator:
    with Session(engine) as session:
        yield session

def get_current_user(
    token: str = Depends(oauth2_scheme),
    session: Session = Depends(get_session)
) -> User:
    if not token:
        # Check cookie if header missing? For now strictly Bearer.
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Check Blacklist First
    if service.is_token_blacklisted(session, token):
        raise HTTPException(status_code=401, detail="Token revoked")

    try:
        payload = jwt.decode(
            token, 
            config.JWT_SECRET, 
            algorithms=[config.JWT_ALGORITHM]
        )
        user_id = payload.get("sub")
        if user_id is None:
             raise HTTPException(status_code=401, detail="Invalid token payload")
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Could not validate credentials")
        
    user = session.get(User, uuid.UUID(user_id))
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
        
    return user

def get_current_admin(user: User = Depends(get_current_user)) -> User:
    """
    Enforce global Admin role (Legacy or New 'admin' role).
    """
    is_admin = False
    if user.role == 'admin': is_admin = True
    if user.assigned_role and user.assigned_role.slug == 'admin': is_admin = True
    
    if not is_admin:
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return user

def require_permission(required_perm: str):
    def dependency(user: User = Depends(get_current_user), session: Session = Depends(get_session)):
        # 1. Admin bypass
        if user.role == 'admin': return user
        if user.assigned_role and user.assigned_role.slug == 'admin': return user
        
        if not user.assigned_role:
             raise HTTPException(status_code=403, detail="No role assigned")
             
        # 2. Check permission
        statement = select(Permission).join(RolePermission).where(
            RolePermission.role_id == user.assigned_role.id,
            Permission.slug == required_perm
        )
        perm = session.exec(statement).first()
        
        if not perm:
            raise HTTPException(status_code=403, detail=f"Missing permission: {required_perm}")
            
        return user
    return dependency

def get_current_user_optional(
    token: Optional[str] = Depends(oauth2_scheme),
    session: Session = Depends(get_session)
) -> Optional[User]:
    if not token:
        return None
    
    # Check Blacklist
    if service.is_token_blacklisted(session, token):
        return None

    try:
        payload = jwt.decode(
            token, 
            config.JWT_SECRET, 
            algorithms=[config.JWT_ALGORITHM]
        )
        user_id = payload.get("sub")
        if user_id is None: return None
        return session.get(User, uuid.UUID(user_id))
    except Exception:
        return None
