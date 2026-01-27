from fastapi import APIRouter, Depends, HTTPException, Body
from sqlmodel import Session
from pydantic import BaseModel
from typing import Optional

from ..core.database import engine
from . import service

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

@router.post("/auth/login/telegram")
def login_telegram(req: TelegramLogin, session: Session = Depends(get_session)):
    token, msg = service.verify_telegram_login(session, req.dict())
    if not token:
         raise HTTPException(status_code=401, detail=msg)
    return {"access_token": token, "token_type": "bearer"}
