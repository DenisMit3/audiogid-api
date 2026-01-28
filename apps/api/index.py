# Audio Guide 2026 API - Main Entry Point for Vercel
# This file exports 'app' as required by Vercel FastAPI deployment

from fastapi import FastAPI, Request, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
from qstash import Receiver
import logging

logger = logging.getLogger("api.boot")

# Import from api package (relative to this file location)
from api.core.config import config
from api.core.middleware_security import SecurityMiddleware
from api.core.models import Job
from api.core.database import engine
# NOTE: process_job is imported lazily inside job_callback to prevent boot crash
# from billing module failures (PR-43 fix for PR-42 wrong file)

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
admin_tours_router = safe_import_router("api.admin_tours")
admin_pois_router = safe_import_router("api.admin.poi")  # PR-59: Add POI admin router
purchases_router = safe_import_router("api.purchases")
deletion_router = safe_import_router("api.deletion")
yookassa_router = safe_import_router("api.billing.yookassa")
billing_router = safe_import_router("api.billing.router")  # PR-46: Restore missing billing router
auth_router = safe_import_router("api.auth.router")  # PR-58: Auth router

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.14.0",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# --- CORS Middleware (MUST be before other middleware) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Security Middleware (Global) - DISABLED for debug
# app.add_middleware(SecurityMiddleware)

# Health check at root
@app.get("/")
def root():
    return {"status": "ok", "api": "Audio Guide 2026", "version": "1.14.0"}

# Mount routers (ops first for diagnostics)
app.include_router(ops_router, prefix="/v1")
if public_router: app.include_router(public_router, prefix="/v1")
if ingestion_router: app.include_router(ingestion_router, prefix="/v1")
if map_router: app.include_router(map_router, prefix="/v1")
if publish_router: app.include_router(publish_router, prefix="/v1")
if admin_tours_router: app.include_router(admin_tours_router, prefix="/v1")
if admin_pois_router: app.include_router(admin_pois_router, prefix="/v1")  # PR-59: POI routes
if purchases_router: app.include_router(purchases_router, prefix="/v1")
if deletion_router: app.include_router(deletion_router, prefix="/v1")
if yookassa_router: app.include_router(yookassa_router)
if billing_router: app.include_router(billing_router, prefix="/v1")
if auth_router: app.include_router(auth_router, prefix="/v1")  # PR-58: Auth routes

receiver = Receiver(
    current_signing_key=config.QSTASH_CURRENT_SIGNING_KEY,
    next_signing_key=config.QSTASH_NEXT_SIGNING_KEY,
)

@app.get("/api/health")
def health_check_legacy():
    return {"status": "ok", "version": "1.14.0"}

# --- Diagnostic Endpoint ---
@app.get("/api/diagnose-admin")
def diagnose_admin():
    import traceback
    try:
        from api.admin import poi
        return {"status": "ok", "poi_module": str(poi)}
    except Exception as e:
        return {"status": "error", "error": str(e), "traceback": traceback.format_exc()}

@app.post("/api/internal/jobs/callback")
async def job_callback(request: Request):
    raw_body = await request.body()
    signature = request.headers.get("Upstash-Signature")
    if not signature: 
        raise HTTPException(status_code=401, detail="Missing signature")
    try:
        receiver.verify(
            body=raw_body.decode("utf-8"),
            signature=signature,
            url=str(request.url)
        )
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid signature")

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
