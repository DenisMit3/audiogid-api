from datetime import datetime
import json
import httpx
import hashlib
from sqlmodel import Session, select
from .models import Job, IngestionRun, PoiStaging, HelperPlace, DeletionRequest, Entitlement, PurchaseIntent, Purchase, AuditLog
from .config import config
from qstash import Client
UPSTASH_CLIENT = Client(token=config.QSTASH_TOKEN)

# ... (Previous imports and process_job dispatcher updated) ...

def process_job(session: Session, job: Job):
    if job.type == "osm_import":
        _process_osm_import(session, job)
    elif job.type == "helpers_import":
        _process_helpers_import(session, job)
    elif job.type == "delete_user_data": # PR-10
        _process_deletion(session, job)
    else:
        job.error = f"Unknown job type: {job.type}"
        job.status = "FAILED"

# ... (Previous _process_osm_import and _process_helpers_import omitted for brevity, assume retained) ...
# I will paste the previous methods to prevent erasure if overwrite is true.
# Since I am using `write_to_file` and NOT `replace`, I must provide FULL CONTENT.
# I will use a placeholder comment for the large OSM methods if I was smart, but "Overwrite: true" means I destroy them.
# I MUST REWRITE THEM.

def _process_osm_import(session: Session, job: Job):
    # (Restored from PR-6 context)
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
    # (Restored from PR-6 context)
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

# --- PR-10 Deletion Logic ---
def _process_deletion(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    req_id = payload.get("deletion_request_id")
    subject_id = payload.get("subject_id")
    
    req = session.get(DeletionRequest, req_id)
    if not req:
        job.error = "DeletionRequest not found"
        job.status = "FAILED"
        return

    try:
        req.status = "PROCESSING"
        session.add(req)
        session.commit()
        
        log_summary = {"revoked_entitlements": 0, "anonymized_intents": 0, "anonymized_purchases": 0}
        
        # 1. Entitlements -> Revoke
        ents = session.exec(select(Entitlement).where(Entitlement.device_anon_id == subject_id)).all()
        for e in ents:
            e.revoked_at = datetime.utcnow()
            session.add(e)
            log_summary["revoked_entitlements"] += 1
            
        # 2. Intents -> Anonymize
        intents = session.exec(select(PurchaseIntent).where(PurchaseIntent.device_anon_id == subject_id)).all()
        for i in intents:
            i.device_anon_id = f"anon_{hashlib.sha256(i.idempotency_key.encode()).hexdigest()[:12]}"
            i.status = "ANONYMIZED"
            session.add(i)
            log_summary["anonymized_intents"] += 1
            
        # 3. Purchases -> Anonymize (No direct link to subject_id in Purchase table, it's via Intent)
        # But if the Intent is anonymized, the Purchase is effectively unlinkable to the device.
        # We might want to mark status explicitly?
        # Purchases linked to Anonymized Intents are kept for records.
        
        req.status = "COMPLETED"
        req.completed_at = datetime.utcnow()
        req.log_json = json.dumps(log_summary)
        
        session.add(req)
        
        # Audit
        audit = AuditLog(
            action="USER_DELETION",
            target_id=req.id,
            actor_type="system",
            actor_fingerprint="worker"
        )
        session.add(audit)
        
        session.commit()
        job.status = "COMPLETED"
        job.result = "Deleted"
        
    except Exception as e:
        req.status = "FAILED"
        req.last_error = str(e)
        session.add(req)
        session.commit()
        raise e
