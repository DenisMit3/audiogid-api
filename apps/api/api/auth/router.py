from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.database import engine
from ..core.config import config
from ..core.models import User, UserIdentity
from . import service
from .service import create_access_token

router = APIRouter()

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
    token, msg = service.verify_sms_login(session, req.phone, req.code)
    if not token:
        raise HTTPException(status_code=401, detail=msg)
    return {"access_token": token, "token_type": "bearer"}

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
    
    token = create_access_token(user.id, "admin")
    return {"access_token": token, "token_type": "bearer"}

@router.post("/auth/login/telegram")
def login_telegram(req: TelegramLogin, session: Session = Depends(get_session)):
    token, msg = service.verify_telegram_login(session, req.dict())
    if not token:
         raise HTTPException(status_code=401, detail=msg)
    return {"access_token": token, "token_type": "bearer"}
