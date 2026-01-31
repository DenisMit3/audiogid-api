from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlmodel import Session, select
from pydantic import BaseModel
import uuid

from ..core.database import engine
from ..core.config import config
from ..core.models import User, UserIdentity
from . import service
from .service import create_access_token
from .deps import get_current_user, oauth2_scheme

router = APIRouter()

@router.get("/auth/me")
def get_me(user = Depends(get_current_user)):
    return user

class RefreshReq(BaseModel):
    refresh_token: str

@router.post("/auth/logout")
def logout(
    req: Optional[RefreshReq] = None, 
    token: str = Depends(oauth2_scheme), 
    session: Session = Depends(service.Session) # Workaround: service doesn't expose clean session getter, using deps direct
):
    # We need session here to write blacklist
    from .deps import get_session
    session = next(get_session())

    # Blacklist Access Token
    payload = service.verify_token(token, "access")
    if payload:
        # Use simple expiry from payload, or default 30m if missing (should not happen)
        exp = datetime.fromtimestamp(payload["exp"])
        user_id = uuid.UUID(payload["sub"])
        service.blacklist_token(session, token, exp, user_id)
        
    # Blacklist Refresh Token if provided
    if req and req.refresh_token:
         rf_payload = service.verify_token(req.refresh_token, "refresh")
         if rf_payload:
              exp = datetime.fromtimestamp(rf_payload["exp"])
              user_id = uuid.UUID(rf_payload["sub"])
              service.blacklist_token(session, req.refresh_token, exp, user_id)

    return {"status": "ok"}

def get_session():

    with Session(engine) as session:
        yield session

class PhoneInit(BaseModel):
    phone: str

class PhoneVerify(BaseModel):
    phone: str
    code: str

class TelegramLogin(BaseModel):
    id: str
    first_name: Optional[str] = None
    username: Optional[str] = None
    photo_url: Optional[str] = None
    auth_date: str
    hash: str

class EmailLogin(BaseModel):
    email: str
    password: str

@router.post("/auth/login/sms/init")
async def login_sms_init(req: PhoneInit, session: Session = Depends(get_session)):
    success, msg = await service.initiate_sms_login(session, req.phone)
    if not success:
        status = 400
        if "Too many requests" in msg: status = 429
        raise HTTPException(status_code=status, detail=msg)
    return {"status": "sent", "detail": "SMS code sent"}

@router.post("/auth/login/sms/verify")
def login_sms_verify(req: PhoneVerify, session: Session = Depends(get_session)):
    tokens, msg = service.verify_sms_login(session, req.phone, req.code)
    if not tokens:
        raise HTTPException(status_code=401, detail=msg)
    return tokens

@router.post("/auth/refresh")
def refresh_token(req: RefreshReq, session: Session = Depends(get_session)):
    # Check if refresh token is blacklisted
    if service.is_token_blacklisted(session, req.refresh_token):
        raise HTTPException(status_code=401, detail="Refresh token revoked")

    payload = service.verify_token(req.refresh_token, "refresh")
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")
    
    user_id = payload["sub"]
    user = session.get(User, user_id)
    if not user or not user.is_active:
         raise HTTPException(status_code=401, detail="User inactive")
         
    # Rotation: Blacklist old refresh token to prevent reuse (strict security)
    # Expiry for blacklist record = token expiry
    exp = datetime.fromtimestamp(payload["exp"])
    service.blacklist_token(session, req.refresh_token, exp, user.id)

    new_access = service.create_access_token(user.id, user.role)
    new_refresh = service.create_refresh_token(user.id)
    
    return {
        "access_token": new_access,
        "refresh_token": new_refresh, 
        "token_type": "bearer"
    }

@router.post("/auth/login/dev-admin")
def dev_admin_login(
    payload: dict,
    session: Session = Depends(get_session)
):
    if not config.ADMIN_API_TOKEN or payload.get("secret") != config.ADMIN_API_TOKEN:
        from fastapi import HTTPException
        raise HTTPException(401, "Invalid Dev Secret")
        
    # Get or Create Admin User
    identity = session.exec(select(UserIdentity).where(
        UserIdentity.provider == "dev", 
        UserIdentity.provider_id == "admin"
    )).first()
    
    user = None
    if identity:
        identity.last_login = datetime.utcnow()
        session.add(identity)
        user = session.get(User, identity.user_id)
        # Ensure role is admin
        if user.role != "admin":
            user.role = "admin"
            session.add(user)
            session.commit()
    else:
        user = User(role="admin", is_active=True)
        session.add(user)
        session.commit()
        session.refresh(user)
        
        identity = UserIdentity(
            user_id=user.id, 
            provider="dev", 
            provider_id="admin", 
            last_login=datetime.utcnow()
        )
        session.add(identity)
        session.commit()
    
    access_token = create_access_token(user.id, "admin")
    refresh_token = service.create_refresh_token(user.id)
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

@router.post("/auth/login/email")
def login_email(req: EmailLogin, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.email == req.email)).first()
    if not user:
        # Check against hardcoded default user if DB user doesn't exist
        # This acts as a fallback or initial seed if the user hasn't been created yet
        if req.email == "mit333@list.ru" and req.password == "Solnyshko3":
             # Create user on the fly if not exists?
             pass # Will handle creation below
        else:
             raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    verified = False
    if user and user.hashed_password:
        verified = service.verify_password(req.password, user.hashed_password)
    elif req.email == "mit333@list.ru" and req.password == "Solnyshko3":
        # Create or update user for default credentials
        if not user:
            user = User(email=req.email, role="admin", is_active=True)
            user.hashed_password = service.get_password_hash(req.password)
            session.add(user)
            session.commit()
            session.refresh(user)
            
            # Identity
            identity = UserIdentity(
                user_id=user.id, 
                provider="email", 
                provider_id=req.email, 
                last_login=datetime.utcnow()
            )
            session.add(identity)
            session.commit()
            verified = True
        else:
            # User exists but no password set? Update it
            user.hashed_password = service.get_password_hash(req.password)
            user.role = "admin" # Ensure admin role
            session.add(user)
            session.commit()
            verified = True

    if not verified:
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    # Update last login
    if user:
        identity = session.exec(select(UserIdentity).where(
            UserIdentity.user_id == user.id,
            UserIdentity.provider == "email"
        )).first()
        if identity:
            identity.last_login = datetime.utcnow()
            session.add(identity)
            session.commit()

    access_token = create_access_token(user.id, user.role)
    refresh_token = service.create_refresh_token(user.id)
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

@router.post("/auth/login/telegram")
def login_telegram(req: TelegramLogin, session: Session = Depends(get_session)):
    tokens, msg = service.verify_telegram_login(session, req.dict())
    if not tokens:
         raise HTTPException(status_code=401, detail=msg)
    return tokens
