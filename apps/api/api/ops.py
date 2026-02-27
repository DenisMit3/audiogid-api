from fastapi import APIRouter, Depends, HTTPException, Response, Header, Request
from sqlmodel import Session, text, select
from .core.database import engine
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/ops/app-version")
def check_app_version(
    platform: str = "android",
    version: str = "1.0.0",
    device_id: str = None  # Опционально для аналитики
):
    """
    Проверка версии приложения.
    Читает конфигурацию из ENV переменных.
    
    Args:
        platform: "android" или "ios"
        version: текущая версия приложения (например "1.0.0")
        device_id: идентификатор устройства (опционально, для аналитики)
    
    Returns:
        - update_required: bool - требуется ли обновление
        - force_update: bool - блокировать ли приложение без обновления
        - min_version: str - минимальная поддерживаемая версия
        - current_version: str - последняя доступная версия
        - store_url: str - ссылка на магазин приложений
        - message_ru: str - сообщение для пользователя
    """
    from .core.config import config
    
    platform = platform.lower()
    if platform not in ["android", "ios"]:
        platform = "android"
    
    # Читаем из config (ENV)
    if platform == "android":
        min_version = config.APP_MIN_VERSION_ANDROID
        current_version = config.APP_CURRENT_VERSION_ANDROID
        force_update_enabled = config.APP_FORCE_UPDATE_ANDROID
        store_url = config.APP_STORE_URL_ANDROID
    else:
        min_version = config.APP_MIN_VERSION_IOS
        current_version = config.APP_CURRENT_VERSION_IOS
        force_update_enabled = config.APP_FORCE_UPDATE_IOS
        store_url = config.APP_STORE_URL_IOS
    
    # Парсинг версий
    def parse_version(v: str) -> tuple:
        try:
            parts = v.split(".")
            return tuple(int(p) for p in parts[:3])
        except:
            return (0, 0, 0)
    
    user_ver = parse_version(version)
    min_ver = parse_version(min_version)
    current_ver = parse_version(current_version)
    
    update_required = user_ver < min_ver
    update_available = user_ver < current_ver
    
    # Логирование для аналитики
    logger.info(
        "app_version_check",
        extra={
            "platform": platform,
            "user_version": version,
            "min_version": min_version,
            "current_version": current_version,
            "update_required": update_required,
            "update_available": update_available,
            "device_id": device_id,
        }
    )
    
    # Сообщение
    message_ru = config.APP_UPDATE_MESSAGE_RU or None
    if not message_ru:
        if update_required:
            message_ru = "Ваша версия приложения устарела. Пожалуйста, обновите приложение для продолжения работы."
        elif update_available:
            message_ru = "Доступна новая версия приложения с улучшениями и исправлениями."
    
    return {
        "update_required": update_required,
        "update_available": update_available,
        "force_update": force_update_enabled and update_required,
        "min_version": min_version,
        "current_version": current_version,
        "store_url": store_url,
        "message_ru": message_ru
    }

@router.get("/ops/health")
def health_check():
    """
    Liveness probe. Always 200 if app is running.
    """
    checks = []
    error = None
    status = "ok"

    # Lazy check config imports to diagnose env
    try:
        from .core.config import config
        checks.append("config_import")
    except Exception as e:
        status = "fail"
        error = f"Config Error: {str(e)}"

    return {"status": status, "checks": checks, "error": error}

@router.get("/ops/check-ratings-import")
def check_ratings_import(request: Request):
    """Check if ratings router can be imported and is registered"""
    try:
        from .admin.ratings import router as ratings_router
        # Check if ratings routes are in app
        ratings_paths = [r.path for r in request.app.routes if hasattr(r, 'path') and 'rating' in r.path]
        return {
            "status": "ok", 
            "routes_count": len(ratings_router.routes),
            "ratings_in_app": ratings_paths,
            "ratings_router_routes": [r.path for r in ratings_router.routes]
        }
    except Exception as e:
        import traceback
        return {"status": "error", "error": str(e), "traceback": traceback.format_exc()}

@router.get("/ops/routes")
def list_routes(request: Request):
    """List all registered routes for debugging"""
    routes = []
    for route in request.app.routes:
        if hasattr(route, 'path') and hasattr(route, 'methods'):
            routes.append({
                "path": route.path,
                "methods": list(route.methods) if route.methods else []
            })
    # Filter admin routes
    admin_routes = [r for r in routes if '/admin/' in r['path']]
    return {"total": len(routes), "admin_routes": admin_routes}

@router.get("/ops/commit")
def get_commit():
    import os
    import datetime
    return {
        "commit_sha": os.getenv("GIT_COMMIT_SHA", "unknown"),
        "commit_msg": os.getenv("GIT_COMMIT_MESSAGE", "unknown"),
        "deploy_env": os.getenv("DEPLOY_ENV", "development"),
        "timestamp": datetime.datetime.utcnow().isoformat()
    }

@router.get("/ops/ready")
def readiness_check(session: Session = Depends(get_session)):
    """
    Readiness probe. Checks DB connection.
    Returns 500 if DB unavailable.
    """
    try:
        # Simple query
        session.exec(text("SELECT 1"))
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database Unavailable: {str(e)}")

@router.get("/ops/config-check")
def config_check():
    from .core.config import config
    return {
        "OPENAI_API_KEY": bool(config.OPENAI_API_KEY),
        "S3_STORAGE": {
            "S3_ENDPOINT_URL": bool(config.S3_ENDPOINT_URL),
            "S3_ACCESS_KEY": bool(config.S3_ACCESS_KEY),
            "S3_BUCKET_NAME": config.S3_BUCKET_NAME,
        },
        "AUDIO_PROVIDER": config.AUDIO_PROVIDER,
        "QSTASH_TOKEN": bool(config.QSTASH_TOKEN),
        "OVERPASS_API_URL": bool(config.OVERPASS_API_URL),
        "YOOKASSA": {
            "SHOP_ID": bool(config.YOOKASSA_SHOP_ID),
            "SECRET_KEY": bool(config.YOOKASSA_SECRET_KEY),
            "WEBHOOK_SECRET": bool(config.YOOKASSA_WEBHOOK_SECRET),
            "PAYMENT_WEBHOOK_BASE_PATH": bool(config.PAYMENT_WEBHOOK_BASE_PATH)
        },
        "PUBLIC_APP_BASE_URL": bool(config.PUBLIC_APP_BASE_URL),
        "DEPLOY_ENV": config.DEPLOY_ENV
    }

import alembic.config
import alembic.command
import os

@router.post("/ops/init-skus")
def init_skus(session: Session = Depends(get_session)):
    from .core.models import Entitlement
    # Create Kaliningrad City Access SKU
    slug = "kaliningrad_city_access"
    existing = session.exec(select(Entitlement).where(Entitlement.slug == slug)).first()
    if not existing:
        ent = Entitlement(
            slug=slug,
            scope="city",
            ref="kaliningrad_city",
            title_ru="Доступ к Калининграду (Все туры)",
            price_amount=499.0
        )
        session.add(ent)
        session.commit()
        return {"status": "created", "slug": slug}
    return {"status": "exists", "slug": slug}

@router.post("/ops/init-free-tour/{tour_id}")
def init_free_tour(tour_id: str, session: Session = Depends(get_session)):
    """
    Create free entitlement for a tour (no auth required for bootstrap).
    """
    from .core.models import Entitlement
    slug = f"tour_{tour_id}_free"
    existing = session.exec(select(Entitlement).where(Entitlement.slug == slug)).first()
    if existing:
        return {"status": "exists", "slug": slug, "entitlement_id": str(existing.id)}
    
    ent = Entitlement(
        slug=slug,
        scope="tour",
        ref=tour_id,
        title_ru="Бесплатный доступ к туру",
        price_amount=0,
        price_currency="RUB",
        is_active=True
    )
    session.add(ent)
    session.commit()
    session.refresh(ent)
    return {"status": "created", "slug": slug, "entitlement_id": str(ent.id)}

@router.post("/ops/migrate")
def run_migrations(token: str = Header(None)):
    """
    Run alembic migrations programmatically.
    Protected by ADMIN_API_TOKEN.
    """
    from .core.config import config
    if token != config.ADMIN_API_TOKEN:
         raise HTTPException(401, detail="Invalid token")

    try:
        # Assume alembic.ini is in current working directory (apps/api)
        ini_path = "alembic.ini"
        if not os.path.exists(ini_path):
             return {"status": "error", "detail": "alembic.ini not found"}
             
        alembic_cfg = alembic.config.Config(ini_path)
        # Force stdout capture if needed, but for now just running it
        alembic.command.upgrade(alembic_cfg, "head")
        return {"status": "migrated"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}

@router.get("/ops/cron/cleanup-tokens")
def cron_cleanup_tokens(session: Session = Depends(get_session)):
    """
    Cron job to remove expired blacklisted tokens.
    Protected by simple obscurity or Vercel Cron protection header (implement header check if needed).
    For now public but harmless (cleaning up garbage).
    """
    from .auth.tasks import cleanup_blacklisted_tokens
    count = cleanup_blacklisted_tokens(session)
    return {"status": "ok", "deleted_count": count}

