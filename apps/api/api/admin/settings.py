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

class LocationSettings(BaseModel):
    geofence_radius_m: int = 30
    free_walking_radius_m: int = 50
    poi_cooldown_minutes: int = 15
    off_route_threshold_m: int = 100
    auto_play_enabled: bool = True
    background_location_enabled: bool = True
    high_accuracy_mode: bool = False

class GeneralSettings(BaseModel):
    app_name: str = "Аудиогид"
    support_email: str = "support@audiogid.app"
    default_language: str = "ru"
    maintenance_mode: bool = False
    app_version_min: str = "1.0.0"

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

# --- Location Settings ---

@router.get("/admin/settings/location", response_model=LocationSettings)
def get_location_settings(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:read'))
):
    """Получить настройки геолокации"""
    data = get_settings_dict(session, "location")
    
    return LocationSettings(
        geofence_radius_m=data.get("geofence_radius_m", 30),
        free_walking_radius_m=data.get("free_walking_radius_m", 50),
        poi_cooldown_minutes=data.get("poi_cooldown_minutes", 15),
        off_route_threshold_m=data.get("off_route_threshold_m", 100),
        auto_play_enabled=data.get("auto_play_enabled", True),
        background_location_enabled=data.get("background_location_enabled", True),
        high_accuracy_mode=data.get("high_accuracy_mode", False)
    )

@router.put("/admin/settings/location", response_model=LocationSettings)
def update_location_settings(
    settings: LocationSettings,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:write'))
):
    """Обновить настройки геолокации"""
    data = settings.dict()
    save_settings_dict(session, "location", data, admin.id)
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

# --- General Settings ---

@router.get("/admin/settings/general", response_model=GeneralSettings)
def get_general_settings(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:read'))
):
    """Получить общие настройки приложения"""
    data = get_settings_dict(session, "general")
    
    return GeneralSettings(
        app_name=data.get("app_name", "Аудиогид"),
        support_email=data.get("support_email", "support@audiogid.app"),
        default_language=data.get("default_language", "ru"),
        maintenance_mode=data.get("maintenance_mode", False),
        app_version_min=data.get("app_version_min", "1.0.0")
    )

@router.put("/admin/settings/general", response_model=GeneralSettings)
def update_general_settings(
    settings: GeneralSettings,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('settings:write'))
):
    """Обновить общие настройки приложения"""
    data = settings.dict()
    save_settings_dict(session, "general", data, admin.id)
    return settings
