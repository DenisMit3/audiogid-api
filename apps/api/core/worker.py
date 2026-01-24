from datetime import datetime
import json
import httpx
from sqlmodel import Session, select
from .models import Job, IngestionRun, PoiStaging, HelperPlace
from .config import config

# ... (Previous imports and process_job dispatcher same as before) ...
def process_job(session: Session, job: Job):
    if job.type == "osm_import":
        _process_osm_import(session, job)
    elif job.type == "helpers_import":
        _process_helpers_import(session, job)
    else:
        job.error = f"Unknown job type: {job.type}"
        job.status = "FAILED"

def _process_osm_import(session: Session, job: Job):
    # (Same logic as PR-3/4 for Staging, skipping redundant paste)
    # Staging doesn't have geo column, it has raw_payload.
    # We do NOT propagate to POI table here yet (that is Publish step).
    # So no change needed here for geo.
    # ...
    # Wait, strict rules say I should overwrite full content usually?
    # I'll stick to 'no change' assumption if file is huge, but to be safe I'll recreate it fully 
    # if I'm creating a functioning system, I just need to ensure imports are satisfied.
    # But wait! HelperPlace IS written here directly.
    # I need to update HelperPlace writing to include geo.
    pass 
    # ... (Actual code reuse below) ...

# RE-WRITING FULL FILE TO ENSURE HELPER UPDATE
def _process_osm_import(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    boundary_ref = payload.get("boundary_ref")

    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        if not config.OVERPASS_API_URL: raise ValueError("OVERPASS_API_URL not configured")
        rel_id = boundary_ref
        query = f"[out:json][timeout:25]; rel({rel_id}); map_to_area->.a; (node['tourism'](area.a); way['tourism'](area.a); relation['tourism'](area.a);); out center;"
        
        transport_timeout = httpx.Timeout(28.0, connect=5.0)
        try:
            response = httpx.post(config.OVERPASS_API_URL, data={"data": query}, timeout=transport_timeout)
        except httpx.TimeoutException as te:
            raise RuntimeError(f"Overpass Client Timeout: {te}")
            
        if response.status_code != 200: raise RuntimeError(f"Overpass API failed: {response.status_code}")
        
        data = response.json()
        elements = data.get("elements", [])
        count = 0
        for el in elements:
            e_id = f"{el.get('type')}/{el.get('id')}"
            name_ru = el.get("tags", {}).get("name:ru") or el.get("tags", {}).get("name")
            
            stmt = select(PoiStaging).where(PoiStaging.city_slug == city_slug, PoiStaging.osm_id == e_id)
            existing = session.exec(stmt).first()
            if existing:
                existing.raw_payload = json.dumps(el, default=str)
                existing.name_ru = name_ru
                session.add(existing)
            else:
                session.add(PoiStaging(city_slug=city_slug, osm_id=e_id, raw_payload=json.dumps(el, default=str), name_ru=name_ru))
            count += 1
            
        session.commit()
        run.status = "COMPLETED"
        run.finished_at = datetime.utcnow()
        run.stats_json = json.dumps({"imported": count})
        job.result = json.dumps({"run_id": str(run.id), "status": "success", "imported": count})
        
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        job.status = "FAILED"
        job.error = str(e)
    finally:
        session.add(run)
        session.commit()

def _process_helpers_import(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    boundary_id = "319662" if city_slug == "kaliningrad_city" else None
    
    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    if not boundary_id:
        run.status = "FAILED"
        job.status = "FAILED"
        return

    try:
        query = f"[out:json][timeout:25]; rel({boundary_id}); map_to_area->.a; (node['amenity'~'toilets|drinking_water|cafe'](area.a);); out center;"
        
        transport_timeout = httpx.Timeout(28.0, connect=5.0)
        try:
            response = httpx.post(config.OVERPASS_API_URL, data={"data": query}, timeout=transport_timeout)
        except httpx.TimeoutException as te:
            raise RuntimeError(f"Overpass Timeout: {te}")
            
        data = response.json()
        elements = data.get("elements", [])
        count = 0
        
        from geoalchemy2.elements import WKTElement
        from sqlalchemy import text
        
        for el in elements:
            e_id = str(el.get("id"))
            lat, lon = el.get("lat"), el.get("lon")
            if lat is None or lon is None: continue
            
            # PostGIS Point
            # We must construct WKT for "POINT(lon lat)"
            # And enable session to write it. SQLModel might struggle with WKTElement if we typed it as Any.
            # Easiest way using SQLModel with GeoAlchemy2 is WKTElement.
            point_wkt = f"POINT({lon} {lat})"
            
            stmt = select(HelperPlace).where(HelperPlace.city_slug == city_slug, HelperPlace.osm_id == e_id)
            existing = session.exec(stmt).first()
            
            if existing:
                existing.lat = lat
                existing.lon = lon
                existing.geo = WKTElement(point_wkt, srid=4326)
                existing.type = el.get("tags", {}).get("amenity")
                existing.name_ru = el.get("tags", {}).get("name:ru")
                session.add(existing)
            else:
                new_h = HelperPlace(
                    city_slug=city_slug,
                    osm_id=e_id,
                    type=el.get("tags", {}).get("amenity"),
                    lat=lat,
                    lon=lon,
                    name_ru=el.get("tags", {}).get("name:ru"),
                    geo=WKTElement(point_wkt, srid=4326)
                )
                session.add(new_h)
            count += 1
            
        session.commit()
        run.status = "COMPLETED"
        run.finished_at = datetime.utcnow()
        run.stats_json = json.dumps({"imported": count})
        job.result = json.dumps({"run_id": str(run.id)})

    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        job.status = "FAILED"
        job.error = str(e)
    finally:
        session.add(run)
        session.commit()
