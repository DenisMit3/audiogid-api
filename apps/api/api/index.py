from fastapi import FastAPI, Request, HTTPException
from sqlmodel import Session, select
from upstash_qstash import Receiver

from .core.config import config
from .core.middleware import structured_logging_middleware
from .core.models import Job
from .core.database import engine # Need to define this or inline it

app = FastAPI(
    title="Audio Guide 2026 API",
    version="1.0.0",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# QStash Receiver for signature verification
receiver = Receiver({
    "current_signing_key": config.QSTASH_CURRENT_SIGNING_KEY,
    "next_signing_key": config.QSTASH_NEXT_SIGNING_KEY,
})

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    return await structured_logging_middleware(request, call_next)

@app.get("/api/health")
def health_check():
    return {
        "status": "ok", 
        "version": "1.0.0",
        "database_configured": True
    }

@app.post("/api/internal/jobs/callback")
async def job_callback(request: Request):
    """
    Handle QStash callback with strict Security and Idempotency.
    """
    # 1. Verify Signature (Security)
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

    # 2. Parse Payload
    body = await request.json()
    job_id = body.get("job_id")
    if not job_id:
        raise HTTPException(status_code=400, detail="Missing job_id")

    # 3. Idempotency & Processing
    with Session(engine) as session:
        job = session.exec(select(Job).where(Job.id == job_id)).first()
        if not job:
            # Job might not appear yet due to replication lag? Or invalid ID.
            # Fail fast 404
            raise HTTPException(status_code=404, detail="Job not found")
        
        # Idempotency: If already running or completed, ignore
        if job.status in ["RUNNING", "COMPLETED", "FAILED"]:
            return {"status": "idempotent_skip", "job_id": job_id}

        # State Transition
        job.status = "RUNNING"
        session.add(job)
        session.commit()
        
        try:
            # EXECUTE LOGIC HERE (Dispatcher based on job.type)
            # For PR-0, we just acknowledge receipt
            job.status = "COMPLETED"
            job.result = '{"processed": true}'
        except Exception as e:
            job.status = "FAILED"
            job.error = str(e)
        
        session.add(job)
        session.commit()
    
    return {"status": "processed", "job_id": job_id}
