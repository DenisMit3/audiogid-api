# Audio Guide 2026 API - Main Entry Point for Vercel
# This file exports 'app' as required by Vercel FastAPI deployment

from fastapi import FastAPI, Request, HTTPException
from sqlmodel import Session, select
from qstash import Receiver

# Import from api package (relative to this file location)
from api.core.config import config
from api.core.middleware_security import SecurityMiddleware
from api.core.models import Job
from api.core.database import engine
from api.core.worker import process_job

from api.public import router as public_router
from api.ingestion import router as ingestion_router
from api.map import router as map_router
from api.publish import router as publish_router
from api.admin_tours import router as admin_tours_router
from api.purchases import router as purchases_router
from api.deletion import router as deletion_router
from api.ops import router as ops_router

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.11.0",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# Mount Security Middleware (Global)
app.add_middleware(SecurityMiddleware)

# Health check at root
@app.get("/")
def root():
    return {"status": "ok", "api": "Audio Guide 2026", "version": "1.11.0"}

app.include_router(ops_router, prefix="/v1")
app.include_router(public_router, prefix="/v1")
app.include_router(ingestion_router, prefix="/v1")
app.include_router(map_router, prefix="/v1")
app.include_router(publish_router, prefix="/v1")
app.include_router(admin_tours_router, prefix="/v1")
app.include_router(purchases_router, prefix="/v1")
app.include_router(deletion_router, prefix="/v1")

receiver = Receiver(
    current_signing_key=config.QSTASH_CURRENT_SIGNING_KEY,
    next_signing_key=config.QSTASH_NEXT_SIGNING_KEY,
)

@app.get("/api/health")
def health_check_legacy():
    return {"status": "ok", "version": "1.11.0"}

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
            process_job(session, job) 
            if job.status == "RUNNING": 
                job.status = "COMPLETED"
        except Exception as e:
            job.status = "FAILED"
            job.error = str(e)
        session.add(job)
        session.commit()
    return {"status": "processed", "job_id": job_id}
