from datetime import datetime
import json
from sqlmodel import Session
from .models import Job, IngestionRun
from .config import config

def process_job(session: Session, job: Job):
    """
    Main Logic Dispatcher for Async Jobs.
    """
    if job.type == "osm_import":
        _process_osm_import(session, job)
    elif job.type == "helpers_import":
        _process_helpers_import(session, job)
    else:
        job.error = f"Unknown job type: {job.type}"
        job.status = "FAILED"

def _process_osm_import(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    boundary_ref = payload.get("boundary_ref")

    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        # NO FAKE SUCCESS: This logic is a skeleton.
        # We must verify configuration for Overpass. 
        # If not present or logic not implemented, FAIL FAST.
        
        # Check Config (would raise if config is missing, but double check logic vacancy)
        # Assuming we don't have the Overpass client library yet (Phase 1b/2), 
        # we cannot possibly succeed.
        
        # Explicit Fail-Fast:
        raise NotImplementedError("Overpass Import Logic not yet implemented. Cannot mark COMPLETED.")

        # If we had logic:
        # 1. Fetch from Overpass
        # 2. Parse
        # 3. Write to PoiStaging
        # 4. run.status = "COMPLETED"
        # 5. job.status = "COMPLETED"
    
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        run.finished_at = datetime.utcnow()
        
        # Job must enable retry or mark failed. 
        # For unimplemented features, mark FAILED to stop retry loop.
        job.status = "FAILED"
        job.error = str(e)
        
    finally:
        session.add(run)

def _process_helpers_import(session: Session, job: Job):
    # Similar Fail-Fast
    run = IngestionRun(city_slug="unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        raise NotImplementedError("Helpers Import Logic not yet implemented.")
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        job.status = "FAILED"
        job.error = str(e)
    finally:
        session.add(run)
