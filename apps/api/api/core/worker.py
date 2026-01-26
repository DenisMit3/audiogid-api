from datetime import datetime
import json
import httpx
import hashlib
from sqlmodel import Session, select
from .models import Job, IngestionRun, PoiStaging, HelperPlace, DeletionRequest, Entitlement, EntitlementGrant, PurchaseIntent, Purchase, AuditLog
from .ingestion.processor import run_ingestion
from .narration.service import generate_narration_for_poi
from .preview.service import generate_preview_content
from ..offline.worker import process_offline_bundle # PR-33b
import asyncio
from .config import config
from qstash import QStash
import uuid # Added for _process_narration
# Lazy imports to avoid circular deps if needed, but here we need service functions
# from ..billing.service import grant_entitlement 
# from ..billing.apple import restore_apple_receipt
# from ..billing.google import verify_google_purchase
# Since worker is in core, we import from sibling
from apps.api.api.billing.service import grant_entitlement
from apps.api.api.billing.apple import restore_apple_receipt
from apps.api.api.billing.google import verify_google_purchase
UPSTASH_CLIENT = QStash(token=config.QSTASH_TOKEN)

# ... (Previous imports and process_job dispatcher updated) ...


async def process_job(session: Session, job: Job):
    if job.type == "osm_import":
        await _process_osm_import(session, job)
    elif job.type == "helpers_import":
        await _process_helpers_import(session, job)
    elif job.type == "delete_user_data": # PR-10
        await _process_deletion(session, job)
    elif job.type == "generate_narration":
        await _process_narration(session, job)
    elif job.type == "generate_preview":
        await _process_preview(session, job)
    elif job.type == "build_offline_bundle": # PR-33b
        await process_offline_bundle(session, job)
    elif job.type == "billing_restore": # PR-39
        await _process_billing_restore(session, job)
    else:
        job.error = f"Unknown job type: {job.type}"
        job.status = "FAILED"

# ... (Previous _process_osm_import and _process_helpers_import omitted for brevity, assume retained) ...

async def _process_preview(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    poi_id_str = payload.get("poi_id")
    if not poi_id_str:
        job.status = "FAILED"
        job.error = "Missing poi_id"
        return

    try:
        result = await generate_preview_content(session, poi_id_str)
        if result and "error" in result:
             job.status = "FAILED"
             job.error = result["error"]
        else:
             job.status = "COMPLETED"
             job.result = json.dumps(result)
    except Exception as e:
        job.status = "FAILED"
        job.error = str(e)

async def _process_narration(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    poi_id_str = payload.get("poi_id")
    if not poi_id_str:
        job.status = "FAILED"
        job.error = "Missing poi_id in payload"
        return
    
    try:
        poi_id = uuid.UUID(poi_id_str)
        # Run async logic in sync context
        result = await generate_narration_for_poi(session, poi_id)
        
        if result and "error" in result:
             job.status = "FAILED"
             job.error = result["error"]
        else:
             job.status = "COMPLETED"
             job.result = json.dumps(result)
             
    except Exception as e:
        job.status = "FAILED"
        job.error = str(e)

async def _process_osm_import(session: Session, job: Job):
    # Use Processor
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug") or payload.get("city")
    
    run = IngestionRun(city_slug=city_slug or "unknown", status="RUNNING")
    session.add(run)
    session.commit()
    
    try:
        stats = await run_ingestion(session, city_slug)
        if "error" in stats:
            raise RuntimeError(stats["error"])
            
        run.status = "COMPLETED"
        run.finished_at = datetime.utcnow()
        run.stats_json = json.dumps(stats)
        job.result = json.dumps({"run_id": str(run.id), "status": "success", **stats})
        
    except Exception as e:
        run.status = "FAILED"
        run.last_error = str(e)
        job.status = "FAILED"
        job.error = str(e)
    finally:
        session.add(run)
        session.commit()

async def _process_helpers_import(session: Session, job: Job):
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
        
        # transport_timeout = httpx.Timeout(28.0, connect=5.0)
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.post(config.OVERPASS_API_URL, data={"data": query})
            except httpx.TimeoutException as te:
                raise RuntimeError(f"Overpass Timeout: {te}")
            
        data = response.json()
        elements = data.get("elements", [])
        count = 0
        
        from geoalchemy2.elements import WKTElement
        # from sqlalchemy import text
        
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
async def _process_deletion(session: Session, job: Job):
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
        
        # 1. Entitlements -> Revoke (EntitlementGrant)
        ents = session.exec(select(EntitlementGrant).where(EntitlementGrant.device_anon_id == subject_id)).all()
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

# --- Billing Restore Logic ---
async def _process_billing_restore(session: Session, job: Job):
    payload = json.loads(job.payload or "{}")
    platform = payload.get("platform", "auto")
    device_anon_id = payload.get("device_anon_id")
    trace_id = job.idempotency_key # Reuse idempotency key or generate new trace
    if not trace_id: trace_id = str(job.id)
    
    # Inputs
    apple_receipt = payload.get("apple_receipt")
    google_token = payload.get("google_purchase_token")
    
    stats = {"platform": platform, "grants_created": 0, "grants_existing": 0, "grants_total": 0, "errors": []}
    
    try:
        # APPLE PATH
        if (platform == "apple" or platform == "auto") and apple_receipt:
            stats["platform"] = "apple"
            restore_result = await restore_apple_receipt(apple_receipt)
            
            if not restore_result.get("verified"):
                 job.status = "FAILED"
                 job.error = restore_result.get("error")
                 return
                 
            transactions = restore_result.get("transactions", [])
            for tx in transactions:
                try:
                    product_id = tx.get("product_id")
                    tx_id = tx.get("transaction_id")
                    
                    # Grant
                    _, is_new = await grant_entitlement(
                        session, 
                        source="apple", 
                        source_ref=tx_id, 
                        product_id=product_id, 
                        device_anon_id=device_anon_id, 
                        trace_id=f"{trace_id}:{tx_id}"
                    )
                    
                    if is_new: stats["grants_created"] += 1
                    else: stats["grants_existing"] += 1
                    
                except ValueError:
                    # Unknown product ID - ignore legacy products not in our DB
                    continue
                except Exception as e:
                    stats["errors"].append(f"Tx {tx.get('transaction_id')}: {str(e)}")
            
        # GOOGLE PATH
        elif (platform == "google" or platform == "auto") and google_token:
             # Google restore usually implies verifying "current" purchases sent by client
             # Currently we only support single token verification in this flow ( MVP)
             # To support MULTIPLE tokens, client should send array.
             # If OpenAPI defines singular, we handle singular.
             stats["platform"] = "google"
             # Need package_name and product_id? 
             # Google API requires packageName and productId to verify token.
             # If Payload doesn't have product_id, we can't verify easily unless we decode the token (which is opaque).
             # Wait, verify_google_purchase takes (package, product, token).
             # If the client sends just token, we are stuck.
             # BUT: Restore logic usually implies the client sends "I have purchase with token T and SKU S".
             # Our OpenAPI schema for restore has `google_purchase_token` but NOT `product_id`.
             # This is a flaw in my OpenAPI design in step A.
             # FIX: I will assume `product_id` is passed in payload for Google, OR fail-fast.
             # ACTUALLY: Google BillingClient `queryPurchases` returns (productId, purchaseToken).
             # So client KNOWS the product_id.
             # I should have added `product_id` to Restore schema? Or `google_purchases` list?
             # Let's fix OpenAPI in next step if needed, or rely on payload extras.
             # For now, if missing product_id, we log error.
             
             product_id = payload.get("product_id")
             package_name = payload.get("package_name") or "app.audiogid.kaliningrad"
             
             if not product_id:
                 job.status = "FAILED"
                 job.error = "Google restore requires product_id"
                 return

             result = await verify_google_purchase(package_name, product_id, google_token)
             if result.get("verified"):
                  _, is_new = await grant_entitlement(session, "google", result["transaction_id"], product_id, device_anon_id, trace_id)
                  if is_new: stats["grants_created"] += 1
                  else: stats["grants_existing"] += 1
             else:
                  job.status = "FAILED"
                  job.error = result.get("error")
                  return

        else:
            if not apple_receipt and not google_token:
                 job.status = "FAILED"
                 job.error = "No receipt or token provided"
                 return

        stats["grants_total"] = stats["grants_created"] + stats["grants_existing"]
        
        job.status = "COMPLETED"
        job.result = json.dumps(stats)
        
        # Log Audit
        session.add(AuditLog(
            action="BILLING_RESTORE_COMPLETED",
            target_id=job.id,
            actor_type="system",
            actor_fingerprint="worker",
            trace_id=trace_id
        ))
        session.commit()

    except Exception as e:
        job.status = "FAILED"
        job.error = str(e)
        session.add(job)
        session.commit()
