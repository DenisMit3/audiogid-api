import os
import httpx
from .config import config
from .models import Job
from sqlmodel import Session

async def enqueue_job(job_type: str, payload: str, session: Session, idempotency_key: str | None = None) -> Job:
    """
    Canonical Async Pattern:
    1. Persist Job (PENDING) to DB.
    2. Call QStash to enqueue callback.
    """
    # 1. Persist
    job = Job(type=job_type, payload=payload, status="PENDING", idempotency_key=idempotency_key)
    session.add(job)
    session.commit()
    session.refresh(job)
    
    # 2. Enqueue in QStash
    # Fail-fast: Config already validated QSTASH_TOKEN exists.
    headers = {
        "Authorization": f"Bearer {config.QSTASH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    # Callback URL must be the public endpoint of the API.
    # Use PUBLIC_URL or PUBLIC_APP_BASE_URL for self-hosted deployments.
    base_url = config.PUBLIC_URL or os.getenv("PUBLIC_APP_BASE_URL") or "http://82.202.159.64:8000"
    # Ensure no trailing slash and proper protocol
    base_url = base_url.rstrip('/')
    if not base_url.startswith('http'):
        base_url = f"https://{base_url}"
        
    destination = f"{base_url}/api/internal/jobs/callback"
    
    # Debug Logging
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Enqueuing Job {job.id} to QStash. Dest: {destination}")
    
    async with httpx.AsyncClient() as client:
        # Use configured QStash URL (e.g. for US-East-1)
        response = await client.post(
            f"{config.QSTASH_URL}/v2/publish/{destination}",
            headers=headers,
            json={"job_id": str(job.id)}
        )
        
        if response.status_code != 200 and response.status_code != 201:
            # We explicitly do NOT rollback the DB here because we want the record of failure?
            # Or we follow canonical pattern: if enqueue fails, mark job as FAILED immediately?
            job.status = "FAILED"
            job.error = f"QStash enqueue failed: {response.text}"
            session.add(job)
            session.commit()
            raise RuntimeError(f"QStash Enqueue Failed: {response.text}")
            
    return job
