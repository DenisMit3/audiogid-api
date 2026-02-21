from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import logging
import httpx
import json

from ..core.database import engine
from ..core.models import User, UserPushToken, AppSettings
from ..auth.deps import get_current_user_optional, require_permission, get_session

logger = logging.getLogger(__name__)
router = APIRouter()

class PushRegisterReq(BaseModel):
    token: str
    device_id: str
    platform: str = "unknown"

class PushSendReq(BaseModel):
    target: str = "all"  # "all", "android", "ios", или конкретный user_id
    title: str
    body: str
    data: Optional[dict] = None

class PushSendResponse(BaseModel):
    status: str
    recipient_count: int
    success_count: int
    failure_count: int
    errors: List[str] = []

@router.post("/push/register")
def register_token(
    req: PushRegisterReq, 
    session: Session = Depends(get_session),
    user: Optional[User] = Depends(get_current_user_optional)
):
    """Регистрация push-токена устройства"""
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

def get_fcm_key(session: Session) -> Optional[str]:
    """Получить FCM ключ из настроек"""
    setting = session.get(AppSettings, "notifications.fcm_server_key")
    if setting:
        try:
            return json.loads(setting.value)
        except json.JSONDecodeError:
            return setting.value
    return None

async def send_fcm_message(fcm_key: str, token: str, title: str, body: str, data: Optional[dict] = None) -> tuple[bool, str]:
    """Отправить push через FCM Legacy HTTP API"""
    url = "https://fcm.googleapis.com/fcm/send"
    headers = {
        "Authorization": f"key={fcm_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "to": token,
        "notification": {
            "title": title,
            "body": body,
            "sound": "default"
        }
    }
    
    if data:
        payload["data"] = data
    
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(url, headers=headers, json=payload)
            
            if response.status_code == 200:
                result = response.json()
                if result.get("success", 0) > 0:
                    return True, ""
                else:
                    error = result.get("results", [{}])[0].get("error", "Unknown error")
                    return False, error
            else:
                return False, f"HTTP {response.status_code}"
    except Exception as e:
        logger.error(f"FCM send error: {e}")
        return False, str(e)

@router.post("/admin/notifications/push", response_model=PushSendResponse)
async def send_push_notification(
    req: PushSendReq,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('notifications:send'))
):
    """Отправить push-уведомление (админ)"""
    
    # Получаем FCM ключ
    fcm_key = get_fcm_key(session)
    if not fcm_key:
        raise HTTPException(status_code=400, detail="FCM Server Key не настроен. Перейдите в Настройки -> Уведомления.")
    
    # Получаем токены по фильтру
    query = select(UserPushToken)
    
    if req.target == "android":
        query = query.where(UserPushToken.platform == "android")
    elif req.target == "ios":
        query = query.where(UserPushToken.platform == "ios")
    elif req.target != "all":
        # Предполагаем что это user_id
        try:
            import uuid
            user_id = uuid.UUID(req.target)
            query = query.where(UserPushToken.user_id == user_id)
        except ValueError:
            raise HTTPException(status_code=400, detail="Неверный target. Используйте 'all', 'android', 'ios' или UUID пользователя.")
    
    tokens = session.exec(query).all()
    
    if not tokens:
        return PushSendResponse(
            status="completed",
            recipient_count=0,
            success_count=0,
            failure_count=0,
            errors=["Нет зарегистрированных устройств"]
        )
    
    # Отправляем push каждому устройству
    success_count = 0
    failure_count = 0
    errors = []
    invalid_tokens = []
    
    for push_token in tokens:
        success, error = await send_fcm_message(
            fcm_key, 
            push_token.token, 
            req.title, 
            req.body, 
            req.data
        )
        
        if success:
            success_count += 1
        else:
            failure_count += 1
            if error not in errors:
                errors.append(error)
            
            # Помечаем невалидные токены для удаления
            if error in ["NotRegistered", "InvalidRegistration"]:
                invalid_tokens.append(push_token.token)
    
    # Удаляем невалидные токены
    for token in invalid_tokens:
        t = session.get(UserPushToken, token)
        if t:
            session.delete(t)
    
    if invalid_tokens:
        session.commit()
        logger.info(f"Removed {len(invalid_tokens)} invalid push tokens")
    
    return PushSendResponse(
        status="completed",
        recipient_count=len(tokens),
        success_count=success_count,
        failure_count=failure_count,
        errors=errors[:5]  # Ограничиваем количество ошибок
    )

@router.get("/admin/notifications/stats")
def get_push_stats(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('notifications:read'))
):
    """Статистика push-токенов"""
    all_tokens = session.exec(select(UserPushToken)).all()
    
    android_count = sum(1 for t in all_tokens if t.platform == "android")
    ios_count = sum(1 for t in all_tokens if t.platform == "ios")
    unknown_count = sum(1 for t in all_tokens if t.platform not in ["android", "ios"])
    
    return {
        "total": len(all_tokens),
        "android": android_count,
        "ios": ios_count,
        "unknown": unknown_count
    }
