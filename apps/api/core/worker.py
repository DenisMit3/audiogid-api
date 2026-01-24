from datetime import datetime
import json
import httpx
from sqlmodel import Session, select
from .models import Job, IngestionRun, PoiStaging
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
        if not config.OVERPASS_API_URL:
             raise ValueError("OVERPASS_API_URL not configured")
             
        # Generate Overpass QL
        rel_id = boundary_ref
        
        # [timeout:25] instructs Overpass server to kill query after 25s.
        query = f"""
        [out:json][timeout:25];
        rel({rel_id});
        map_to_area->.a;
        (
          node["tourism"](area.a);
          way["tourism"](area.a);
          relation["tourism"](area.a);
        );
        out center;
        """
        
        # Client-side Safety: Vercel functions have limits (10s Hobby / 60s Pro).
        # We enforce a client timeout to avoid hanging the lambda indefinitely
        # and to catch the error explicitly instead of hard crashing.
        # We allow 28s total (connect 5s, read 23s) to define failure before platform kills us.
        transport_timeout = httpx.Timeout(28.0, connect=5.0)
        
        try:
            response = httpx.post(
                config.OVERPASS_API_URL, 
                data={"data": query}, 
                timeout=transport_timeout
            )
        except httpx.TimeoutException as te:
            raise RuntimeError(f"Overpass Client Timeout ({transport_timeout}): {str(te)}")
        
        if response.status_code != 200:
            raise RuntimeError(f"Overpass API failed: {response.status_code} {response.text[:200]}")
            
        data = response.json()
        elements = data.get("elements", [])
        
        if not elements:
            # If valid query returned 0 elements, we still mark COMPLETED but count is 0.
            # This is technically "successful import of nothing".
            pass

        count_upserted = 0
        
        for el in elements:
            e_type = el.get("type")
            e_id = el.get("id")
            osm_unique_id = f"{e_type}/{e_id}"
            
            tags = el.get("tags", {})
            name_ru = tags.get("name:ru") or tags.get("name")
            
            stmt = select(PoiStaging).where(
                PoiStaging.city_slug == city_slug,
                PoiStaging.osm_id == osm_unique_id
            )
            existing = session.exec(stmt).first()
            
            if existing:
                existing.raw_payload = json.dumps(el, default=str)
                existing.name_ru = name_ru
                session.add(existing)
            else:
                new_poi = PoiStaging(
                    city_slug=city_slug,
                    osm_id=osm_unique_id,
                    raw_payload=json.dumps(el, default=str),
                    name_ru=name_ru
                )
                session.add(new_poi)
            
            count_upserted += 1
            
        session.commit()
        
        run.status = "COMPLETED"
        run.finished_at = datetime.utcnow()
        run.stats_json = json.dumps({"imported": count_upserted, "total_elements": len(elements)})
        
        job.result = json.dumps({"run_id": str(run.id), "status": "success", "imported": count_upserted})
        
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        run.finished_at = datetime.utcnow()
        
        job.status = "FAILED"
        job.error = str(e)
        
    finally:
        session.add(run)
        session.commit()

def _process_helpers_import(session: Session, job: Job):
    # Explicit Fail-Fast for unimplemented feature
    run = IngestionRun(city_slug="unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        raise NotImplementedError("Helpers Import Logic Not Implemented")
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        
        job.status = "FAILED"
        job.error = "Not Implemented" # Clean error message
    finally:
        session.add(run)
        session.commit()
