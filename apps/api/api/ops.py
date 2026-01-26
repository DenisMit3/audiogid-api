from fastapi import APIRouter, Depends, HTTPException, Response
from sqlmodel import Session, text
from .core.database import engine

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/ops/health")
def health_check():
    """
    Liveness probe. Always 200 if app is running.
    """
    return {"status": "ok", "timestamp": "now"}

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
        "VERCEL_BLOB_READ_WRITE_TOKEN": bool(config.VERCEL_BLOB_READ_WRITE_TOKEN),
        "AUDIO_PROVIDER": config.AUDIO_PROVIDER,
        "QSTASH_TOKEN": bool(config.QSTASH_TOKEN),
        "OVERPASS_API_URL": bool(config.OVERPASS_API_URL),
        "YOOKASSA": {
            "SHOP_ID": bool(config.YOOKASSA_SHOP_ID),
            "SECRET_KEY": bool(config.YOOKASSA_SECRET_KEY),
            "WEBHOOK_SECRET": bool(config.YOOKASSA_WEBHOOK_SECRET),
            "PAYMENT_WEBHOOK_BASE_PATH": bool(config.PAYMENT_WEBHOOK_BASE_PATH)
        },
        "PUBLIC_APP_BASE_URL": bool(config.PUBLIC_APP_BASE_URL)
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

@router.post("/ops/migrate")
def run_migrations():
    """
    Run alembic migrations programmatically.
    n/a: out of scope; requires separate ADR security model.
    """
    try:
        # Assume alembic.ini is in current working directory (apps/api)
        ini_path = "alembic.ini"
        if not os.path.exists(ini_path):
             return {"status": "error", "detail": "alembic.ini not found"}
             
        alembic_cfg = alembic.config.Config(ini_path)
        alembic.command.upgrade(alembic_cfg, "head")
        return {"status": "migrated"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}
