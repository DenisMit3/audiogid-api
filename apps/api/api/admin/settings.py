"""
Admin Settings API - управление настройками приложения
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import json

from ..core.database import engine
from ..core.models import User, AppSettings
from ..auth.deps import get_session, require_permission

router = APIRouter()

# --- Schemas ---

class NotificationSettings(BaseModel):
    fcm_server_key: Optional[str] = ""
    email_sender_name: str = "Audiogid Support"
    email_sender_address: str = "support@audiogid.app"
    enable_push: bool = True
    enable_email: bool = False

class AISettings(BaseModel):
    tts_provider: str = "openai"
    openai_api_key: Optional[str] = ""
    default_voice: str = "alloy"
    enable_translation: bool = True

# --- Helpers ---

def get_settings_dict(session: Session, prefix: str) -> dict:
    """Получить все настройки с указанным префиксом как dict"""
    settings = session.exec(
        select(AppSettings).where(AppSettings.key.startswith(prefix))
    ).all()
    result = {}
    for s in settings:
        key = s.key.replace(f"{prefix}.", "")
        try:
            result[key] = json.loads(s.value)
        except json.JSONDecodeError:
            result[key] = s.value
    return result

def save_settings_dict(session: Session, prefix: str, data: dict, user_id) -> None:
    """Сохранить dict как настройки с префиксом"""
    for key, value in data.items():
        full_key = f"{prefix}.{key}"
        existing = session.get(AppSettings, full_key)
        
        str_value = json.dumps(value) if not isinstance(value, str) else value
        
        if existing:
            existing.value = str_value
            existing.updated_at = datetime.utcnow()
            existing.updated_by = user_id
            session.add(existing)
        else:
            new_setting = AppSettings(
                key=full_key,
                value=str_value,
                updated_by=user_id
            )
            session.add(new_setting)
    session.commit()

# --- Notification Settings ---

@router.get("/admin/settings/notifications", response_model=NotificationSettings)
def get_notification_settings(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:read'))
):
    """Получить настройки уведомлений"""
    data = get_settings_dict(session, "notifications")
    
    # Маскируем FCM ключ для безопасности
    if data.get("fcm_server_key"):
        key = data["fcm_server_key"]
        if len(key) > 8:
            data["fcm_server_key"] = key[:4] + "..." + key[-4:]
    
    return NotificationSettings(
        fcm_server_key=data.get("fcm_server_key", ""),
        email_sender_name=data.get("email_sender_name", "Audiogid Support"),
        email_sender_address=data.get("email_sender_address", "support@audiogid.app"),
        enable_push=data.get("enable_push", True),
        enable_email=data.get("enable_email", False)
    )

@router.put("/admin/settings/notifications", response_model=NotificationSettings)
def update_notification_settings(
    settings: NotificationSettings,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:write'))
):
    """Обновить настройки уведомлений"""
    data = settings.dict()
    
    # Если FCM ключ замаскирован, не перезаписываем
    if data.get("fcm_server_key") and "..." in data["fcm_server_key"]:
        existing = get_settings_dict(session, "notifications")
        data["fcm_server_key"] = existing.get("fcm_server_key", "")
    
    save_settings_dict(session, "notifications", data, admin.id)
    return settings

# --- AI Settings ---

@router.get("/admin/settings/ai", response_model=AISettings)
def get_ai_settings(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:read'))
):
    """Получить настройки ИИ"""
    data = get_settings_dict(session, "ai")
    
    # Маскируем API ключ
    if data.get("openai_api_key"):
        key = data["openai_api_key"]
        if len(key) > 8:
            data["openai_api_key"] = key[:4] + "..." + key[-4:]
    
    return AISettings(
        tts_provider=data.get("tts_provider", "openai"),
        openai_api_key=data.get("openai_api_key", ""),
        default_voice=data.get("default_voice", "alloy"),
        enable_translation=data.get("enable_translation", True)
    )

@router.put("/admin/settings/ai", response_model=AISettings)
def update_ai_settings(
    settings: AISettings,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:write'))
):
    """Обновить настройки ИИ"""
    data = settings.dict()
    
    # Если API ключ замаскирован, не перезаписываем
    if data.get("openai_api_key") and "..." in data["openai_api_key"]:
        existing = get_settings_dict(session, "ai")
        data["openai_api_key"] = existing.get("openai_api_key", "")
    
    save_settings_dict(session, "ai", data, admin.id)
    return settings

# --- Get raw setting (for internal use) ---

def get_raw_setting(session: Session, key: str) -> Optional[str]:
    """Получить сырое значение настройки (для внутреннего использования)"""
    setting = session.get(AppSettings, key)
    if setting:
        try:
            return json.loads(setting.value)
        except json.JSONDecodeError:
            return setting.value
    return None
