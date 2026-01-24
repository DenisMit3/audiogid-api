from datetime import datetime
import json
import httpx
from sqlmodel import Session, select
from .models import Job, IngestionRun, PoiStaging, HelperPlace
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
    # Existing Overpass Import Logic
    # (Re-stating briefly since this file overwrites previous content, 
    # ensuring we keep the logic from PR-3)
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    boundary_ref = payload.get("boundary_ref")

    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        if not config.OVERPASS_API_URL:
             raise ValueError("OVERPASS_API_URL not configured")
             
        rel_id = boundary_ref
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
        
        transport_timeout = httpx.Timeout(28.0, connect=5.0)
        try:
            response = httpx.post(config.OVERPASS_API_URL, data={"data": query}, timeout=transport_timeout)
        except httpx.TimeoutException as te:
            raise RuntimeError(f"Overpass Client Timeout ({transport_timeout}): {str(te)}")
            
        if response.status_code != 200:
            raise RuntimeError(f"Overpass API failed: {response.status_code}")
            
        data = response.json()
        elements = data.get("elements", [])
        
        count_upserted = 0
        for el in elements:
            e_type = el.get("type")
            e_id = el.get("id")
            osm_unique_id = f"{e_type}/{e_id}"
            
            tags = el.get("tags", {})
            name_ru = tags.get("name:ru") or tags.get("name")
            
            stmt = select(PoiStaging).where(PoiStaging.city_slug == city_slug, PoiStaging.osm_id == osm_unique_id)
            existing = session.exec(stmt).first()
            if existing:
                existing.raw_payload = json.dumps(el, default=str)
                existing.name_ru = name_ru
                session.add(existing)
            else:
                new_poi = PoiStaging(city_slug=city_slug, osm_id=osm_unique_id, raw_payload=json.dumps(el, default=str), name_ru=name_ru)
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
    # PR-4: Real Helpers Implementation
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    # For now, we assume global boundary logic or pass boundary_ref?
    # PR-2 defined HelpersImportRequest as just city_slug.
    # To use map_to_area, we need the boundary_ref if dynamic, or we reuse one if known.
    # For MVP PR-4, let's assume valid city_slug implies known boundary or passed in payload?
    # But enqueue endpoint in PR-2 didn't take boundary_ref.
    # CRITICAL FIX: We need boundary_ref for map_to_area. 
    # Or we assume 'kaliningrad_city' maps to '319662' via config lookup?
    # Let's enforce fail-fast if no boundary logic available.
    # Assumption: The job payload MIGHT have it if we update Enqueue? No, interface locked.
    # Mitigation: Since we don't have a City -> Boundary config table yet, 
    # we will fail if not 'kaliningrad_city' (hardcoded for Day 1 MVP) or update Enqueue in future.
    # Better: Use Name Search? Too risky. 
    # DECISION: Hardcode Kaliningrad Boundary for PR-4 demonstration if city=kaliningrad_city.
    
    boundary_id = "319662" if city_slug == "kaliningrad_city" else None
    if not boundary_id and city_slug == "kaliningrad_oblast": boundary_id = "514777" # Example ID
    
    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    if not boundary_id:
        # Cannot proceed without boundary
        run.status = "FAILED"
        run.last_error = "Missing Boundary ID resolution for city"
        run.finished_at = datetime.utcnow()
        session.add(run)
        session.commit()
        job.status = "FAILED"
        job.error = "Missing Boundary ID"
        return

    try:
        if not config.OVERPASS_API_URL:
             raise ValueError("OVERPASS_API_URL not configured")
             
        query = f"""
        [out:json][timeout:25];
        rel({boundary_id});
        map_to_area->.a;
        (
          node["amenity"~"toilets|drinking_water|cafe"](area.a);
        );
        out center;
        """
        
        transport_timeout = httpx.Timeout(28.0, connect=5.0)
        try:
            response = httpx.post(config.OVERPASS_API_URL, data={"data": query}, timeout=transport_timeout)
        except httpx.TimeoutException as te:
            raise RuntimeError(f"Overpass Client Timeout: {str(te)}")
            
        if response.status_code != 200:
            raise RuntimeError(f"Overpass API failed: {response.status_code}")
            
        data = response.json()
        elements = data.get("elements", [])
        
        count_upserted = 0
        for el in elements:
            e_id = str(el.get("id"))
            # Type is always Node per query
            tags = el.get("tags", {})
            category = tags.get("amenity") # toilets, drinking_water, cafe
            
            # Upsert
            stmt = select(HelperPlace).where(
                HelperPlace.city_slug == city_slug,
                HelperPlace.osm_id == e_id
            )
            existing = session.exec(stmt).first()
            
            if existing:
                existing.lat = el.get("lat")
                existing.lon = el.get("lon")
                existing.type = category
                existing.name_ru = tags.get("name:ru") or tags.get("name")
                session.add(existing)
            else:
                new_helper = HelperPlace(
                    city_slug=city_slug,
                    osm_id=e_id,
                    type=category,
                    lat=el.get("lat"),
                    lon=el.get("lon"),
                    name_ru=tags.get("name:ru") or tags.get("name")
                )
                session.add(new_helper)
            count_upserted += 1
            
        session.commit()
        run.status = "COMPLETED"
        run.finished_at = datetime.utcnow()
        run.stats_json = json.dumps({"imported": count_upserted})
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
