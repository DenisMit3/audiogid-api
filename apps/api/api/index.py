from fastapi import FastAPI, Request, HTTPException
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from sqlmodel import Session, select
from qstash import Receiver

from .core.config import config
# Updated Middleware Import
from .core.middleware_security import SecurityMiddleware # security headers + redaction

from .core.models import Job
from .core.database import engine
from .core.models import Job
from .core.database import engine
# worker import moved to callback to prevent ImportErrors crashing app boot

import logging
logger = logging.getLogger("api")

# Lazy Import Safe
try:
    from .public import router as public_router
except Exception as e:
    logger.error(f"Failed to import public router: {e}")
    public_router = None

try:
    from .ingestion import router as ingestion_router
except Exception as e:
    logger.error(f"Failed to import ingestion router: {e}")
    ingestion_router = None

try:
    from .map import router as map_router
except Exception as e:
    logger.error(f"Failed to import map router: {e}")
    map_router = None

try:
    from .publish import router as publish_router
except Exception as e:
    logger.error(f"Failed to import publish router: {e}")
    publish_router = None

try:
    from .admin.tours import router as admin_tours_router # PR-59 Refactor
except Exception as e:
    logger.error(f"Failed to import admin_tours router: {e}")
    admin_tours_router = None

try:
    from .admin.poi import router as admin_pois_router # PR-59 New
except Exception as e:
    logger.error(f"Failed to import admin_pois router: {e}")
    admin_pois_router = None



try:
    from .admin.qrcodes import router as admin_qr_router
except Exception as e:
    logger.error(f"Failed to import admin_qr router: {e}")
    admin_qr_router = None

try:
    from .admin.jobs import router as admin_jobs_router
except Exception as e:
    logger.error(f"Failed to import admin_jobs router: {e}")
    admin_jobs_router = None



try:
    from .admin.cities import router as admin_cities_router
    print(f"[DEBUG] admin_cities_router loaded: {admin_cities_router}")
    logger.info(f"admin_cities_router loaded successfully: {admin_cities_router}")
except Exception as e:
    print(f"[DEBUG] Failed to import admin_cities router: {e}")
    logger.error(f"Failed to import admin_cities router: {e}")
    admin_cities_router = None

try:
    from .admin.validation import router as admin_validation_router
except Exception as e:
    logger.error(f"Failed to import admin_validation router: {e}")
    admin_validation_router = None


try:
    from .admin.media import router as admin_media_router
except Exception as e:
    logger.error(f"Failed to import admin_media router: {e}")
    admin_media_router = None

try:
    from .admin.entitlements import router as admin_entitlements_router
except Exception as e:
    logger.error(f"Failed to import admin_entitlements router: {e}")
    admin_entitlements_router = None

try:
    from .admin.helpers import router as admin_helpers_router
except Exception as e:
    logger.error(f"Failed to import admin_helpers router: {e}")
    admin_helpers_router = None

try:
    from .admin.itineraries import router as admin_itineraries_router
except Exception as e:
    logger.error(f"Failed to import admin_itineraries router: {e}")
    admin_itineraries_router = None

try:
    from .admin.settings import router as admin_settings_router
except Exception as e:
    logger.error(f"Failed to import admin_settings router: {e}")
    admin_settings_router = None

try:
    from .admin.analytics import router as admin_analytics_router
except Exception as e:
    logger.error(f"Failed to import admin_analytics router: {e}")
    admin_analytics_router = None

try:
    from .admin.users import router as admin_users_router
except Exception as e:
    logger.error(f"Failed to import admin_users router: {e}")
    admin_users_router = None

try:
    from .admin.audit import router as admin_audit_router
except Exception as e:
    logger.error(f"Failed to import admin_audit router: {e}")
    admin_audit_router = None

try:
    from .admin.ratings import router as admin_ratings_router
    logger.info("admin_ratings_router imported successfully")
    print(f"[STARTUP] admin_ratings_router imported: {admin_ratings_router}, routes: {len(admin_ratings_router.routes)}")
except Exception as e:
    import traceback
    logger.error(f"Failed to import admin_ratings router: {e}\n{traceback.format_exc()}")
    print(f"[STARTUP] admin_ratings_router FAILED: {e}")
    admin_ratings_router = None

try:
    from .purchases import router as purchases_router
except Exception as e:
    logger.error(f"Failed to import purchases router: {e}")
    purchases_router = None

try:
    from .deletion import router as deletion_router
except Exception as e:
    logger.error(f"Failed to import deletion router: {e}")
    deletion_router = None

try:
    from .ops import router as ops_router # PR-11
except Exception as e:
    logger.error(f"Failed to import ops router: {e}")
    # Ops router MUST work for diagnostics; define minimal fallback locally
    from fastapi import APIRouter
    ops_router = APIRouter()
    @ops_router.get("/v1/ops/health")
    def fallback_health(): return {"status": "fallback", "error": str(e)}

try:
    from .offline.router import router as offline_router # PR-33b
except Exception as e:
    logger.error(f"Failed to import offline router: {e}")
    offline_router = None

try:
    from .billing.router import router as billing_router # PR-36c
except Exception as e:
    logger.error(f"Failed to import billing router: {e}")
    billing_router = None

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.13.0 TEST",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# --- Rate Limiter ---
limiter = Limiter(key_func=get_remote_address, default_limits=["200/minute"])
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)


# Mount CORS Middleware
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow ALL origins
    allow_credentials=False, # Must be False for wildcard origin
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Security Middleware (Global)
# app.add_middleware(SecurityMiddleware)

app.include_router(ops_router, prefix="/v1") # Ops first
if public_router: app.include_router(public_router, prefix="/v1")
if ingestion_router: app.include_router(ingestion_router, prefix="/v1")
if map_router: app.include_router(map_router, prefix="/v1")
if admin_tours_router: app.include_router(admin_tours_router, prefix="/v1")
if admin_pois_router: app.include_router(admin_pois_router, prefix="/v1")  # POI routes before publish to use Bearer auth
if publish_router: app.include_router(publish_router, prefix="/v1")  # publish routes after POI (has duplicate /admin/pois with x-admin-token)
if admin_qr_router: app.include_router(admin_qr_router, prefix="/v1")
if admin_jobs_router: app.include_router(admin_jobs_router, prefix="/v1")
if admin_cities_router:
    print(f"[DEBUG] Adding admin_cities_router to app")
    app.include_router(admin_cities_router, prefix="/v1")
else:
    print(f"[DEBUG] admin_cities_router is None, not adding")
if admin_validation_router: app.include_router(admin_validation_router, prefix="/v1")
if admin_media_router: app.include_router(admin_media_router, prefix="/v1")
if admin_entitlements_router: app.include_router(admin_entitlements_router, prefix="/v1")
if admin_helpers_router: app.include_router(admin_helpers_router, prefix="/v1")
if admin_itineraries_router: app.include_router(admin_itineraries_router, prefix="/v1")
if admin_settings_router: app.include_router(admin_settings_router, prefix="/v1")
if admin_analytics_router: app.include_router(admin_analytics_router, prefix="/v1")
if admin_users_router: app.include_router(admin_users_router, prefix="/v1")
if admin_audit_router: app.include_router(admin_audit_router, prefix="/v1")
if admin_ratings_router: 
    app.include_router(admin_ratings_router, prefix="/v1")
    logger.info("admin_ratings_router registered successfully")
    print(f"[STARTUP] admin_ratings_router REGISTERED in app")
else:
    logger.error("admin_ratings_router is None - not registered!")
    print(f"[STARTUP] admin_ratings_router is None - NOT REGISTERED!")
if purchases_router: app.include_router(purchases_router, prefix="/v1")
if deletion_router: app.include_router(deletion_router, prefix="/v1")
if offline_router: app.include_router(offline_router, prefix="/v1")
if billing_router: app.include_router(billing_router, prefix="/v1")

try:
    from .auth.router import router as auth_router # PR-58
except Exception as e:
    logger.error(f"Failed to import auth router: {e}")
    auth_router = None

if auth_router: app.include_router(auth_router, prefix="/v1")

try:
    from .push.router import router as push_router
except Exception as e:
    logger.error(f"Failed to import push router: {e}")
    push_router = None

if push_router: app.include_router(push_router, prefix="/v1")

receiver = Receiver(
    current_signing_key=config.QSTASH_CURRENT_SIGNING_KEY,
    next_signing_key=config.QSTASH_NEXT_SIGNING_KEY,
)

@app.get("/api/health")
def health_check_legacy():
    # Legacy path alias
    return {"status": "ok", "version": "1.13.0 TEST"}

@app.post("/api/internal/jobs/callback")
async def job_callback(request: Request):
    raw_body = await request.body()
    signature = request.headers.get("Upstash-Signature")
    if not signature: raise HTTPException(status_code=401, detail="Missing signature")
    # Fix: Vercel might report http:// internally, but QStash signed https://
    verify_url = str(request.url)
    if verify_url.startswith("http://"):
        verify_url = verify_url.replace("http://", "https://", 1)

    try:
        receiver.verify(
            body=raw_body.decode("utf-8"),
            signature=signature,
            url=verify_url
        )
    except Exception as e:
        logger.error(f"QStash Signature Verify Failed: {e}. ReqURL: {request.url} Corrected: {verify_url} Sig: {signature[:10]}...")
        # Hint: check if http vs https mismatch behind proxy
        raise HTTPException(status_code=401, detail="Invalid signature")

    body = await request.json()
    job_id = body.get("job_id")
    logger.info(f"Received QStash Callback for Job {job_id}")
    if not job_id: raise HTTPException(status_code=400, detail="Missing job_id")

    with Session(engine) as session:
        job = session.exec(select(Job).where(Job.id == job_id)).first()
        if not job: raise HTTPException(status_code=404, detail="Job not found")
        if job.status in ["RUNNING", "COMPLETED", "FAILED"]: return {"status": "idempotent_skip", "job_id": job_id}

        job.status = "RUNNING"
        session.add(job)
        session.commit()
        try:
            from .core.worker import process_job
            await process_job(session, job) 
            if job.status == "RUNNING": job.status = "COMPLETED"
        except ImportError as ie:
            logger.error(f"Worker Import Error: {ie}")
            # Do NOT crash. Fail the job gracefully.
            job.status = "FAILED"
            job.error = f"Worker Import Failed: {str(ie)}"
            # Also consider 503 if critical? But callback should ack.
        except Exception as e:
            job.status = "FAILED"
            job.error = str(e)
        session.add(job)
        session.commit()
    return {"status": "processed", "job_id": job_id}

# --- Diagnostic Endpoint ---
@app.get("/api/diagnose-admin")
def diagnose_admin():
    import traceback
    try:
        from .admin import poi
        return {"status": "ok", "poi_module": str(poi)}
    except Exception as e:
        return {"status": "error", "error": str(e), "traceback": traceback.format_exc()}

@app.get("/api/diagnose-routers")
def diagnose_routers():
    """Check which routers are loaded"""
    return {
        "admin_cities_router": str(admin_cities_router) if admin_cities_router else None,
        "admin_tours_router": str(admin_tours_router) if admin_tours_router else None,
        "admin_pois_router": str(admin_pois_router) if admin_pois_router else None,
        "all_routes_with_cities": [r.path for r in app.routes if "cities" in str(r.path)],
        "total_routes": len(app.routes)
    }