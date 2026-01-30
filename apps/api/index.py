# Audio Guide 2026 API - Main Entry Point for Vercel
# This file exports 'app' as required by Vercel FastAPI deployment

from fastapi import FastAPI, Request, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from sqlmodel import Session, select
from qstash import Receiver
import logging
import os

logger = logging.getLogger("api.boot")

# Import from api package (relative to this file location)
from api.core.config import config
from api.core.middleware_security import SecurityMiddleware
from api.core.models import Job
from api.core.database import engine
# NOTE: process_job is imported lazily inside job_callback to prevent boot crash
# from billing module failures (PR-43 fix for PR-42 wrong file)

# Phase 10: Audit Middleware
from starlette.middleware.base import BaseHTTPMiddleware
from api.core.audit import set_audit_context, clear_audit_context
from api.core.middleware_timeout import TimeoutMiddleware
from api.core.middleware_ratelimit import RateLimitMiddleware

class AuditMiddleware(BaseHTTPMiddleware):
# ...
    async def dispatch(self, request: Request, call_next):
        # Try to extract user from state if AuthMiddleware ran, or just pass request
        # Since Auth happens in dependencies usually, global middleware might not have user yet.
        # But we can store Request.
        set_audit_context(request, getattr(request.state, 'user', None))
        try:
            response = await call_next(request)
            return response
        finally:
            clear_audit_context()


# PR-44: Wrap ALL router imports in try/except to prevent boot crash
# If any router fails to import, app still starts with /v1/ops/* available

def safe_import_router(module_path: str, router_name: str = "router"):
    """Safely import a router, return None on failure"""
    try:
        import importlib
        module = importlib.import_module(module_path)
        return getattr(module, router_name)
    except Exception as e:
        logger.error(f"Failed to import {module_path}: {e}")
        return None

# Critical: ops_router MUST have fallback for diagnostics
try:
    from api.ops import router as ops_router
except Exception as e:
    logger.error(f"Failed to import ops router: {e}")
    ops_router = APIRouter()
    @ops_router.get("/ops/health")
    def fallback_health(): 
        return {"status": "fallback", "boot_error": str(e), "fix": "check logs for import errors"}
    @ops_router.get("/ops/commit")
    def fallback_commit():
        return {"sha": "unknown", "boot_error": str(e)}

public_router = safe_import_router("api.public")
ingestion_router = safe_import_router("api.ingestion")
map_router = safe_import_router("api.map")
publish_router = safe_import_router("api.publish")
admin_tours_router = safe_import_router("api.admin.tours")
admin_pois_router = safe_import_router("api.admin.poi")  # PR-59: Add POI admin router
admin_analytics_router = safe_import_router("api.admin.analytics") # Phase 6
admin_users_router = safe_import_router("api.admin.users")
admin_audit_router = safe_import_router("api.admin.audit")
purchases_router = safe_import_router("api.purchases")
deletion_router = safe_import_router("api.deletion")
yookassa_router = safe_import_router("api.billing.yookassa")
billing_router = safe_import_router("api.billing.router")  # PR-46: Restore missing billing router
auth_router = safe_import_router("api.auth.router")  # PR-58: Auth router
admin_media_router = safe_import_router("api.admin.media")
admin_validation_router = safe_import_router("api.admin.validation")
offline_router = safe_import_router("api.offline.router")

# --- Sentry Initialization ---
if config.SENTRY_DSN:
    try:
        import sentry_sdk
        from sentry_sdk.integrations.fastapi import FastApiIntegration
        from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration
        
        sentry_sdk.init(
            dsn=config.SENTRY_DSN,
            environment=os.getenv("VERCEL_ENV", "development"),
            traces_sample_rate=0.1, # 10% sampling
            integrations=[
                FastApiIntegration(transaction_style="endpoint"),
                SqlalchemyIntegration(),
            ],
        )
        logger.info("Sentry initialized")
    except ImportError:
        logger.warning("sentry-sdk not found, skipping Sentry init")
    except Exception as e:
        logger.error(f"Sentry init failed: {e}")

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.15.6",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# --- CORS Middleware (MUST be before other middleware) ---
# Default origins + optional ones from env
_default_origins = [
    "https://audiogid.app",
    "https://admin.audiogid.app",
    "https://*.vercel.app",  # Preview deployments
]
_env_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
allowed_origins = list(set(_default_origins + [o.strip() for o in _env_origins if o.strip()]))


if os.getenv("VERCEL_ENV") == "preview":
    vercel_url = os.getenv("VERCEL_URL")
    if vercel_url:
        allowed_origins.append(f"https://{vercel_url}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Security Middleware (Global) - enabled in production
app.add_middleware(SecurityMiddleware)
app.add_middleware(RateLimitMiddleware)
app.add_middleware(TimeoutMiddleware)
app.add_middleware(AuditMiddleware)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Health check at root
@app.get("/")
def root():
    return {"status": "ok", "api": "Audio Guide 2026", "version": "1.15.6"}

# Mount routers (ops first for diagnostics)
app.include_router(ops_router, prefix="/v1")
if public_router: app.include_router(public_router, prefix="/v1")
if ingestion_router: app.include_router(ingestion_router, prefix="/v1")
if map_router: app.include_router(map_router, prefix="/v1")
if publish_router: app.include_router(publish_router, prefix="/v1")
if admin_tours_router: app.include_router(admin_tours_router, prefix="/v1")
if admin_pois_router: app.include_router(admin_pois_router, prefix="/v1")  # PR-59: POI routes
if admin_analytics_router: app.include_router(admin_analytics_router, prefix="/v1")
if admin_users_router: app.include_router(admin_users_router, prefix="/v1")
if admin_audit_router: app.include_router(admin_audit_router, prefix="/v1")
if purchases_router: app.include_router(purchases_router, prefix="/v1")
if deletion_router: app.include_router(deletion_router, prefix="/v1")
if yookassa_router: app.include_router(yookassa_router)
if billing_router: app.include_router(billing_router, prefix="/v1")

if auth_router: app.include_router(auth_router, prefix="/v1")  # PR-58: Auth routes
if admin_media_router: app.include_router(admin_media_router, prefix="/v1")
if admin_validation_router: app.include_router(admin_validation_router, prefix="/v1")
if offline_router: app.include_router(offline_router, prefix="/v1")

deeplinks_router = safe_import_router("api.deeplinks")
if deeplinks_router: app.include_router(deeplinks_router) # No prefix for .well-known

analytics_router = safe_import_router("api.analytics.router")
if analytics_router: app.include_router(analytics_router, prefix="/v1") # Phase 5

# QStash Receiver for webhook verification
if config.QSTASH_CURRENT_SIGNING_KEY:
    receiver = Receiver(
        current_signing_key=config.QSTASH_CURRENT_SIGNING_KEY,
        next_signing_key=config.QSTASH_NEXT_SIGNING_KEY,
    )
else:
    logger.warning("QSTASH_CURRENT_SIGNING_KEY not set. Webhook verification will be disabled (SECURITY RISK).")
    receiver = None


@app.get("/api/health")
def health_check_legacy():
    return {"status": "ok", "version": "1.15.6"}

# --- Diagnostic Endpoint ---
@app.get("/api/diagnose-admin")
def diagnose_admin():
    import traceback
    try:
        from api.admin import poi
        return {"status": "ok", "poi_module": str(poi)}
    except Exception as e:
        return {"status": "error", "error": str(e), "traceback": traceback.format_exc()}

@app.get("/api/diagnose-routers")
def diagnose_routers():
    return {
        "admin_pois_router": str(admin_pois_router) if admin_pois_router else "NOT LOADED",
        "admin_tours_router": str(admin_tours_router) if admin_tours_router else "NOT LOADED",
        "auth_router": str(auth_router) if auth_router else "NOT LOADED",
        "public_router": str(public_router) if public_router else "NOT LOADED",
    }

@app.get("/api/diagnose-routes")
def diagnose_routes():
    routes = []
    for route in app.routes:
        if hasattr(route, "path"):
            routes.append(f"{route.methods} {route.path}")
    return {"routes": routes}

@app.get("/api/diagnose-db")
def diagnose_db():
    try:
        with Session(engine) as session:
            # Try simple query
            from sqlalchemy import text
            result = session.exec(text("SELECT 1")).all()
            return {"status": "ok", "result": str(result), "engine": str(engine.url)}
    except Exception as e:
        import traceback
        return {"status": "error", "error": str(e), "traceback": traceback.format_exc()}

@app.post("/api/internal/jobs/callback")
async def job_callback(request: Request):
    raw_body = await request.body()
    signature = request.headers.get("Upstash-Signature")
    if not signature: 
        raise HTTPException(status_code=401, detail="Missing signature")
    
    if receiver:
        try:
            receiver.verify(
                body=raw_body.decode("utf-8"),
                signature=signature,
                url=str(request.url)
            )
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid signature")
    else:
        logger.warning("Skipping signature verification because QSTASH_CURRENT_SIGNING_KEY is not set.")


    body = await request.json()
    job_id = body.get("job_id")
    if not job_id: 
        raise HTTPException(status_code=400, detail="Missing job_id")

    with Session(engine) as session:
        job = session.exec(select(Job).where(Job.id == job_id)).first()
        if not job: 
            raise HTTPException(status_code=404, detail="Job not found")
        if job.status in ["RUNNING", "COMPLETED", "FAILED"]: 
            return {"status": "idempotent_skip", "job_id": job_id}

        job.status = "RUNNING"
        session.add(job)
        session.commit()
        try:
            # PR-43: Lazy import to prevent boot crash from billing/worker failures
            from api.core.worker import process_job
            await process_job(session, job) 
            if job.status == "RUNNING": 
                job.status = "COMPLETED"
        except Exception as e:
            job.status = "FAILED"
            job.error = str(e)
        session.add(job)
        session.commit()
    return {"status": "processed", "job_id": job_id}

import signal
import sys

def shutdown_handler(signum, frame):
    logger.info("Received shutdown signal, cleaning up...")
    # Close DB connections, flush logs, etc.
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown_handler)
signal.signal(signal.SIGINT, shutdown_handler)
