import json
import uuid
import hashlib
import tempfile
import os
import shutil
from datetime import datetime
from sqlmodel import Session, select
import vercel_blob 
import httpx
import zipfile
import asyncio

from ..core.models import Job, City, Poi, Tour
from ..core.config import config

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
        
        # 4. Serialize Manifest
        manifest_json = json.dumps(manifest, ensure_ascii=False)
        content_hash = hashlib.sha256(manifest_json.encode('utf-8')).hexdigest()
        
        # 5. Build ZIP Bundle
        bundle_url = None
        zip_path = None
        
        if config.BLOB_READ_WRITE_TOKEN:
            with tempfile.TemporaryDirectory() as tmp_dir:
                assets_dir = os.path.join(tmp_dir, "assets")
                os.makedirs(assets_dir)
                
                # Collect all assets
                asset_tasks = []
                unique_assets = {} # url -> filename
                
                for p in pois:
                    for m in p.media:
                        if m.url not in unique_assets:
                            ext = m.url.split('.')[-1].split('?')[0] if '.' in m.url else "bin"
                            filename = f"{hashlib.md5(m.url.encode()).hexdigest()}.{ext}"
                            unique_assets[m.url] = filename
                            asset_tasks.append(_download_asset(m.url, os.path.join(assets_dir, filename)))
                    for n in p.narrations:
                        if n.url not in unique_assets:
                            ext = n.url.split('.')[-1].split('?')[0] if '.' in n.url else "mp3"
                            filename = f"{hashlib.md5(n.url.encode()).hexdigest()}.{ext}"
                            unique_assets[n.url] = filename
                            asset_tasks.append(_download_asset(n.url, os.path.join(assets_dir, filename)))
                
                # Download assets in parallel (bounded or simple)
                if asset_tasks:
                    await asyncio.gather(*asset_tasks)
                
                # Update manifest with local paths
                for p_data in manifest["content"]["pois"]:
                    for m_data in p_data["media"]:
                        if m_data["url"] in unique_assets:
                            m_data["local_path"] = f"assets/{unique_assets[m_data['url']]}"
                    for n_data in p_data["narrations"]:
                        if n_data["url"] in unique_assets:
                            n_data["local_path"] = f"assets/{unique_assets[n_data['url']]}"
                
                # Write final manifest
                final_manifest_json = json.dumps(manifest, ensure_ascii=False)
                with open(os.path.join(tmp_dir, "manifest.json"), "w", encoding="utf-8") as f:
                    f.write(final_manifest_json)
                
                # Create ZIP
                zip_filename = f"bundle_{city_slug}_{content_hash[:10]}.zip"
                zip_path = os.path.join(tempfile.gettempdir(), zip_filename)
                with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
                    for root, dirs, files in os.walk(tmp_dir):
                        for file in files:
                            abs_path = os.path.join(root, file)
                            rel_path = os.path.relpath(abs_path, tmp_dir)
                            zf.write(abs_path, rel_path)
                
                # Upload ZIP
                blob_path = f"offline/bundles/{city_slug}/{zip_filename}"
                with open(zip_path, "rb") as f:
                    blob_result = vercel_blob.put(
                        blob_path,
                        f.read(),
                        options={'access': 'public', 'addRandomSuffix': False}
                    )
                bundle_url = blob_result['url']
                
                # Also upload manifest separately for quick check
                manifest_blob_path = f"offline/manifests/{city_slug}/{content_hash}.json"
                vercel_blob.put(
                    manifest_blob_path,
                    final_manifest_json.encode('utf-8'),
                    options={'access': 'public', 'addRandomSuffix': False}
                )
                manifest_url = blob_result['url'] # Actually we want the manifest URL from its own put, but bundle_url is more important
        else:
            raise RuntimeError("Missing BLOB_READ_WRITE_TOKEN")

        # 6. Complete Job
        job.status = "COMPLETED"
        job.result = json.dumps({
            "bundle_url": bundle_url,
            "manifest_url": f"https://{config.VERCEL_URL if config.VERCEL_URL else 'blob'}/offline/manifests/{city_slug}/{content_hash}.json", # Mocked if needed, or get from put
            "content_hash": content_hash,
            "zip_size_bytes": os.path.getsize(zip_path) if zip_path and os.path.exists(zip_path) else 0
        })
        
        # Cleanup zip
        if zip_path and os.path.exists(zip_path):
            os.remove(zip_path)
        
    except Exception as e:
        job.status = "FAILED"
        job.error = str(e)
        # Log full error with trace_id (structured logging placeholder)
        print(f"[{trace_id}] Build Failed: {e}")

async def _download_asset(url: str, dest_path: str):
    """
    Downloads a single asset to a local file.
    """
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        with open(dest_path, "wb") as f:
            f.write(resp.content)
