from fastapi import APIRouter, Depends
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..core.database import engine
from ..core.models import User, UserPushToken
from ..auth.deps import get_current_user_optional

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

class PushRegisterReq(BaseModel):
    token: str
    device_id: str
    platform: str = "unknown"

@router.post("/push/register")
def register_token(
    req: PushRegisterReq, 
    session: Session = Depends(get_session),
    user: Optional[User] = Depends(get_current_user_optional)
):
    # Check if token exists
    existing = session.get(UserPushToken, req.token)
    if existing:
        existing.updated_at = datetime.utcnow()
        if user:
            existing.user_id = user.id
        existing.device_id = req.device_id
        session.add(existing)
    else:
        new_token = UserPushToken(
            token=req.token,
            device_id=req.device_id,
            platform=req.platform,
            user_id=user.id if user else None
        )
        session.add(new_token)
    
    session.commit()
    return {"status": "ok"}

@router.post("/push/send")
def send_push(
    payload: dict,
    session: Session = Depends(get_session)
):
    # Placeholder for admin push
    return {"status": "queued"}
