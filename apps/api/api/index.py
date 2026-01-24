from fastapi import FastAPI, Request, HTTPException
from sqlmodel import Session, select
from upstash_qstash import Receiver

from .core.config import config
from .core.middleware import structured_logging_middleware
from .core.models import Job
from .core.database import engine
from .core.worker import process_job

from .public import router as public_router
from .ingestion import router as ingestion_router
from .map import router as map_router
from .publish import router as publish_router # PR-5

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.5.0",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

app.include_router(public_router, prefix="/v1")
app.include_router(ingestion_router, prefix="/v1")
app.include_router(map_router, prefix="/v1")
app.include_router(publish_router, prefix="/v1")

receiver = Receiver({
    "current_signing_key": config.QSTASH_CURRENT_SIGNING_KEY,
    "next_signing_key": config.QSTASH_NEXT_SIGNING_KEY,
})

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    return await structured_logging_middleware(request, call_next)

@app.get("/api/health")
def health_check():
    return {"status": "ok", "version": "1.5.0"}

@app.post("/api/internal/jobs/callback")
async def job_callback(request: Request):
    """
    Handle QStash callback.
    """
    raw_body = await request.body()
    signature = request.headers.get("Upstash-Signature")
    if not signature:
        raise HTTPException(status_code=401, detail="Missing signature")
    
    try:
        receiver.verify({
            "signature": signature,
            "body": raw_body.decode("utf-8")
        })
    except Exception as e:
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
            # Delegate to Worker
            process_job(session, job) 
            
            # If worker success and didn't fail job explicitly:
            if job.status == "RUNNING":
               job.status = "COMPLETED"
               
        except Exception as e:
            job.status = "FAILED"
            job.error = str(e)
        
        session.add(job)
        session.commit()
    
    return {"status": "processed", "job_id": job_id}
