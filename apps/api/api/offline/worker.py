import json
import uuid
import hashlib
import tempfile
import os
import shutil
from datetime import datetime
from sqlmodel import Session, select
import vercel_blob 

from ..models import Job, City, Poi, Tour
from ..config import config

async def process_offline_bundle(session: Session, job: Job):
    """
    Worker handler for 'build_offline_bundle' job type.
    Generates a JSON manifest for the requested city/bundle and uploads it to Blob Storage.
    """
    
    # 1. Parse Payload
    payload = json.loads(job.payload or "{}")
    city_slug = payload.get("city_slug")
    bundle_type = payload.get("bundle_type")
    trace_id = payload.get("trace_id")
    
    if not city_slug:
        job.status = "FAILED"
        job.error = "Missing city_slug"
        return

    try:
        # 2. Fetch Data (City, Pois, Tours)
        city = session.exec(select(City).where(City.slug == city_slug)).first()
        if not city:
            raise ValueError(f"City not found: {city_slug}")
            
        pois = session.exec(select(Poi).where(Poi.city_slug == city_slug)).all()
        tours = session.exec(select(Tour).where(Tour.city_slug == city_slug)).all()
        
        # 3. Construct Manifest Structure
        # MVP: Embed all metadata directly into the manifest. 
        # Future: generate separate files and zip them.
        
        manifest = {
            "metadata": {
                "bundle_id": str(uuid.uuid4()),
                "type": bundle_type,
                "city_slug": city_slug,
                "city_name_ru": city.name_ru,
                "created_at": datetime.utcnow().isoformat(),
                "version": "1.0",
                "trace_id": trace_id
            },
            "content": {
                "pois": [
                    {
                        "id": str(p.id),
                        "title": p.title_ru,
                        "lat": p.lat,
                        "lon": p.lon,
                        "description": p.description_ru,
                        "media": [
                            {"url": m.url, "type": m.media_type, "id": str(m.id)} 
                            for m in p.media
                        ],
                        "narrations": [
                             {"url": n.url, "locale": n.locale, "duration": n.duration_seconds}
                             for n in p.narrations
                        ]
                    } for p in pois
                ],
                "tours": [
                    {
                        "id": str(t.id),
                        "title": t.title_ru,
                        "duration": t.duration_minutes,
                        "description": t.description_ru,
                         "items": [
                            {"poi_id": str(i.poi_id), "order": i.order_index}
                            for i in t.items
                        ]
                    } for t in tours
                ]
            },
            "assets": [] # Placeholder for list of downloadable assets
        }
        
        # 4. Serialize & Hash
        manifest_json = json.dumps(manifest, ensure_ascii=False)
        content_hash = hashlib.sha256(manifest_json.encode('utf-8')).hexdigest()
        
        # 5. Store Artifact (Vercel Blob)
        if config.BLOB_READ_WRITE_TOKEN:
             # Path: offline/manifests/{city_slug}/{hash}.json
             blob_path = f"offline/manifests/{city_slug}/{content_hash}.json"
             
             # Note: vercel_blob.put returns a dict with 'url'
             blob_result = vercel_blob.put(
                 blob_path, 
                 manifest_json.encode('utf-8'), 
                 options={'access': 'public', 'addRandomSuffix': False}
             )
             manifest_url = blob_result['url']
        else:
            # Fallback for dev/preview without Blob token
            # We fail-fast if strict, but for MVP we might mock or raise
            raise RuntimeError("Missing BLOB_READ_WRITE_TOKEN")

        # 6. Complete Job
        job.status = "COMPLETED"
        job.result = json.dumps({
            "manifest_url": manifest_url,
            "content_hash": content_hash,
            "size_bytes": len(manifest_json)
        })
        
    except Exception as e:
        job.status = "FAILED"
        job.error = str(e)
        # Log full error with trace_id (structured logging placeholder)
        print(f"[{trace_id}] Build Failed: {e}")
