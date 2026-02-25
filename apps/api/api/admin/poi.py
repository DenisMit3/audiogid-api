
import os
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlmodel import Session, select, func, or_
from pydantic import BaseModel
from geoalchemy2.elements import WKTElement
import uuid
import json
from datetime import datetime, timedelta

from ..core.models import Poi, PoiBase, PoiVersion, AuditLog, User, AppEvent, PoiSource, PoiMedia, Narration
from ..auth.deps import get_current_admin, get_session, require_permission
from ..core.config import config as settings
from ..core.async_utils import enqueue_job
import requests

router = APIRouter()

# --- SCHEMAS ---

class PoiCreate(PoiBase):
    pass

class PoiUpdate(BaseModel):
    title_ru: Optional[str] = None
    description_ru: Optional[str] = None
    city_slug: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    preview_audio_url: Optional[str] = None
    preview_bullets: Optional[List[str]] = None
    category: Optional[str] = None
    title_en: Optional[str] = None
    description_en: Optional[str] = None
    address: Optional[str] = None
    opening_hours: Optional[Any] = None
    external_links: Optional[List[str]] = None
    cover_image: Optional[str] = None

class PoiRead(PoiBase):
    id: uuid.UUID
    updated_at: datetime
    published_at: Optional[datetime]
    is_deleted: bool

class PoiSourceRead(BaseModel):
    id: uuid.UUID
    name: str
    url: Optional[str]

class PoiMediaRead(BaseModel):
    id: uuid.UUID
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str

class NarrationRead(BaseModel):
    id: uuid.UUID
    locale: str
    url: str
    duration_seconds: float
    transcript: Optional[str]

class PoiListResponse(BaseModel):
    items: List[PoiRead]
    total: int
    page: int
    per_page: int
    pages: int

class PoiDetailResponse(BaseModel):
    poi: PoiRead
    sources: List[PoiSourceRead]
    media: List[PoiMediaRead]
    narrations: List[NarrationRead]
    can_publish: bool
    publish_issues: List[str]

class CreateSourceReq(BaseModel):
    name: str
    url: Optional[str] = None

class CreateMediaReq(BaseModel):
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str

class CreateNarrationReq(BaseModel):
    url: str
    locale: str = "ru"
    duration_seconds: float
    transcript: Optional[str] = None

class BulkAction(BaseModel):
    ids: List[uuid.UUID]

class PublishCheckResult(BaseModel):
    can_publish: bool
    issues: List[str]

class PresignRequest(BaseModel):
    filename: str
    content_type: str
    entity_type: str
    entity_id: uuid.UUID

class PresignResponse(BaseModel):
    upload_url: str
    final_url: str
    method: str = "PUT"
    headers: Dict[str, str]
    expires_at: datetime

# --- ENDPOINTS ---

@router.get("/admin/pois", response_model=PoiListResponse)
def list_pois(
    city_slug: Optional[str] = None,
    status: Optional[str] = None, # published, draft
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('poi:read'))
):
    query = select(Poi).where(Poi.is_deleted == False)
    
    if city_slug:
        query = query.where(Poi.city_slug == city_slug)
    
    if status == "published":
        query = query.where(Poi.published_at.isnot(None))
    elif status == "draft":
        query = query.where(Poi.published_at.is_(None))
        
    if search:
        query = query.where(or_(
            Poi.title_ru.ilike(f"%{search}%"),
            Poi.description_ru.ilike(f"%{search}%")
        ))
    
    # Count total
    total_query = select(func.count()).select_from(query.subquery())
    total = session.exec(total_query).one()
    
    # Pagination
    query = query.order_by(Poi.updated_at.desc())
    query = query.offset((page - 1) * per_page).limit(per_page)
    items = session.exec(query).all()
    
    return {
        "items": items,
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }

@router.post("/admin/pois", response_model=PoiRead, dependencies=[Depends(require_permission('poi:write'))])
def create_poi(
    poi_in: PoiCreate,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    db_poi = Poi.from_orm(poi_in)
    db_poi.id = uuid.uuid4()
    
    if db_poi.lat is not None and db_poi.lon is not None:
        try:
            db_poi.geo = WKTElement(f"POINT({db_poi.lon} {db_poi.lat})", srid=4326)
        except Exception:
            pass # ignore geo error for now
    
    session.add(db_poi)
    
    # Versioning
    v = PoiVersion(
            poi_id=db_poi.id,
            changed_by=user.id,
            title_ru=db_poi.title_ru,
            description_ru=db_poi.description_ru,
            lat=db_poi.lat,
            lon=db_poi.lon,
            full_snapshot_json=db_poi.json()
    )
    session.add(v)
    
    session.add(AppEvent(event_type="poi_created", user_id=user.id, payload_json=json.dumps({"id": str(db_poi.id), "title": db_poi.title_ru})))
    
    session.commit()
    session.refresh(db_poi)
    return db_poi

@router.get("/admin/pois/{poi_id}", response_model=PoiDetailResponse)
def get_poi(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('poi:read'))
):
    poi = session.get(Poi, poi_id)
    if not poi or poi.is_deleted: raise HTTPException(404, "POI not found")
    
    # Load relations separately
    sources = session.exec(select(PoiSource).where(PoiSource.poi_id == poi_id)).all()
    media = session.exec(select(PoiMedia).where(PoiMedia.poi_id == poi_id)).all()
    narrations = session.exec(select(Narration).where(Narration.poi_id == poi_id)).all()
    
    # Logic for can_publish
    issues = []
    if not poi.description_ru or len(poi.description_ru) < 10: issues.append("Description too short")
    if poi.lat is None: issues.append("Missing coordinates")
    
    # Convert to dict to avoid geo serialization issues
    poi_dict = {
        "id": poi.id,
        "title_ru": poi.title_ru,
        "city_slug": poi.city_slug,
        "description_ru": poi.description_ru,
        "title_en": poi.title_en,
        "description_en": poi.description_en,
        "category": poi.category,
        "address": poi.address,
        "cover_image": poi.cover_image,
        "opening_hours": poi.opening_hours,
        "external_links": poi.external_links,
        "published_at": poi.published_at,
        "lat": poi.lat,
        "lon": poi.lon,
        "osm_id": poi.osm_id,
        "wikidata_id": poi.wikidata_id,
        "confidence_score": poi.confidence_score,
        "preview_audio_url": poi.preview_audio_url,
        "preview_bullets": poi.preview_bullets,
        "updated_at": poi.updated_at,
        "is_deleted": poi.is_deleted,
    }
    
    return {
        "poi": poi_dict,
        "sources": sources,
        "media": media,
        "narrations": narrations,
        "can_publish": len(issues) == 0,
        "publish_issues": issues
    }

@router.patch("/admin/pois/{poi_id}", response_model=PoiRead, dependencies=[Depends(require_permission('poi:write'))])
def update_poi(
    poi_id: uuid.UUID,
    data: PoiUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    poi = session.get(Poi, poi_id)
    if not poi or poi.is_deleted: raise HTTPException(404, "POI not found")
    
    poi_data = data.dict(exclude_unset=True)
    for key, value in poi_data.items():
        setattr(poi, key, value)
    
    if data.lat is not None or data.lon is not None:
        lat = data.lat if data.lat is not None else poi.lat
        lon = data.lon if data.lon is not None else poi.lon
        if lat is not None and lon is not None:
             poi.geo = WKTElement(f"POINT({lon} {lat})", srid=4326)
             poi.lat = lat # Update fields just in case
             poi.lon = lon

    session.add(poi)
    
    v = PoiVersion(
         poi_id=poi.id,
         changed_by=user.id,
         title_ru=poi.title_ru,
         description_ru=poi.description_ru,
         lat=poi.lat,
         lon=poi.lon,
         full_snapshot_json=poi.json()
    )
    session.add(v)
    
    session.add(AppEvent(event_type="poi_edited", user_id=user.id, payload_json=json.dumps({"id": str(poi.id), "changes": list(poi_data.keys())})))

    session.commit()
    session.refresh(poi)
    return poi

@router.delete("/admin/pois/{poi_id}", dependencies=[Depends(require_permission('poi:delete'))])
def delete_poi(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_admin)
):
    poi = session.get(Poi, poi_id)
    if not poi or poi.is_deleted: raise HTTPException(404, "POI not found")
    
    poi.is_deleted = True
    poi.deleted_at = datetime.utcnow()
    poi.published_at = None # Unpublish on delete
    
    session.add(poi)
    session.add(AuditLog(action="DELETE_POI", target_id=poi_id, actor_fingerprint=str(user.id)))
    session.commit()
    return {"status": "deleted"}

# --- Sub-resources ---

@router.post("/admin/pois/{poi_id}/sources", status_code=201)
def add_poi_source(poi_id: uuid.UUID, req: CreateSourceReq, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404)
    source = PoiSource(poi_id=poi_id, name=req.name, url=req.url)
    session.add(source)
    session.commit()
    return {"id": source.id, "name": source.name}

@router.delete("/admin/pois/{poi_id}/sources/{source_id}")
def delete_poi_source(poi_id: uuid.UUID, source_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    source = session.get(PoiSource, source_id)
    if not source or source.poi_id != poi_id: raise HTTPException(404, "Source not found")
    session.delete(source)
    session.commit()
    return {"status": "deleted"}

@router.post("/admin/pois/{poi_id}/media", status_code=201)
def add_poi_media(poi_id: uuid.UUID, req: CreateMediaReq, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404)
    media = PoiMedia(poi_id=poi_id, **req.dict())
    session.add(media)
    session.commit()
    return {"id": media.id}

@router.delete("/admin/pois/{poi_id}/media/{media_id}")
def delete_poi_media(poi_id: uuid.UUID, media_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    media = session.get(PoiMedia, media_id)
    if not media or media.poi_id != poi_id: raise HTTPException(404)
    session.delete(media)
    session.commit()
    return {"status": "deleted"}

@router.post("/admin/pois/{poi_id}/narrations", status_code=201)
def add_poi_narration(poi_id: uuid.UUID, req: CreateNarrationReq, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404)
    narration = Narration(poi_id=poi_id, **req.dict())
    session.add(narration)
    session.commit()
    return {"id": narration.id}

@router.delete("/admin/pois/{poi_id}/narrations/{narration_id}")
def delete_poi_narration(poi_id: uuid.UUID, narration_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:write'))):
    narration = session.get(Narration, narration_id)
    if not narration or narration.poi_id != poi_id: raise HTTPException(404)
    session.delete(narration)
    session.commit()
    return {"status": "deleted"}

# --- Publishing ---

@router.post("/admin/pois/{poi_id}/publish")
def publish_poi(poi_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:publish'))):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404)

    # Gates check
    if not poi.description_ru or len(poi.description_ru) < 10:
        raise HTTPException(400, "Description too short")
    if poi.lat is None:
        raise HTTPException(400, "Missing coordinates")
        
    poi.published_at = datetime.utcnow()
    session.add(poi)
    session.add(AppEvent(event_type="poi_published", entity_id=poi.id, user_id=user.id))
    session.commit()
    return {"status": "published"}

@router.post("/admin/pois/{poi_id}/unpublish")
def unpublish_poi(poi_id: uuid.UUID, session: Session = Depends(get_session), user: User = Depends(require_permission('poi:publish'))):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404)
    poi.published_at = None
    session.add(poi)
    session.commit()
    return {"status": "unpublished"}

@router.post("/admin/pois/bulk-publish")
def bulk_publish_pois(action: BulkAction, session: Session = Depends(get_session), user: User = Depends(get_current_admin)):
    pois = session.exec(select(Poi).where(Poi.id.in_(action.ids))).all()
    count = 0
    now = datetime.utcnow()
    for poi in pois:
        if not poi.published_at:
            poi.published_at = now
            session.add(poi)
            count += 1
    if count: session.commit()
    return {"count": count, "status": "published"}

@router.post("/admin/pois/bulk-unpublish")
def bulk_unpublish_pois(action: BulkAction, session: Session = Depends(get_session), user: User = Depends(get_current_admin)):
    pois = session.exec(select(Poi).where(Poi.id.in_(action.ids))).all()
    count = 0
    for poi in pois:
        if poi.published_at:
            poi.published_at = None
            session.add(poi)
            count += 1
    if count: session.commit()
    return {"count": count, "status": "unpublished"}

@router.post("/admin/pois/bulk-delete")
def bulk_delete_pois(action: BulkAction, session: Session = Depends(get_session), user: User = Depends(get_current_admin)):
    pois = session.exec(select(Poi).where(Poi.id.in_(action.ids))).all()
    count = 0
    for poi in pois:
         poi.is_deleted = False # Soft delete logic often just flags. 
         # Wait, delete_poi uses is_deleted=True.
         poi.is_deleted = True
         poi.published_at = None
         poi.deleted_at = datetime.utcnow()
         session.add(poi)
         count += 1
         
    if count: 
        session.commit()
        
    return {"count": count, "status": "deleted"}

@router.get("/admin/pois/export")
def export_pois_csv(session: Session = Depends(get_session), user: User = Depends(require_permission('poi:read'))):
    # Simple CSV export
    import csv
    import io
    from fastapi.responses import StreamingResponse
    
    # Query all visible POIs
    pois = session.exec(select(Poi).where(Poi.is_deleted == False)).all()
    
    output = io.StringIO()
    writer = csv.writer(output)
    
    # Header
    writer.writerow(["id", "title_ru", "city_slug", "lat", "lon", "published_at", "updated_at"])
    
    for p in pois:
        writer.writerow([
            str(p.id),
            p.title_ru,
            p.city_slug,
            p.lat,
            p.lon,
            p.published_at,
            p.updated_at
        ])
        
    output.seek(0)
    
    response = StreamingResponse(iter([output.getvalue()]), media_type="text/csv")
    response.headers["Content-Disposition"] = "attachment; filename=pois_export.csv"
    return response

# --- Media Presigned URL ---

@router.post("/admin/media/presign", response_model=PresignResponse)
def get_presigned_url(
    req: PresignRequest,
    user: User = Depends(require_permission('media:write'))
):
    """
    Returns a presigned URL for direct upload to S3-compatible storage.
    """
    
    ALLOWED_TYPES = {
        "image/jpeg": {"ext": "jpg", "max": 10},
        "image/png": {"ext": "png", "max": 10},
        "image/webp": {"ext": "webp", "max": 10},
        "audio/mpeg": {"ext": "mp3", "max": 50},
        "audio/wav": {"ext": "wav", "max": 100},
        "audio/ogg": {"ext": "ogg", "max": 50},
    }
    
    if req.content_type not in ALLOWED_TYPES:
        raise HTTPException(400, "Invalid content type")
    
    # Generate path: entity_type/entity_id/uuid_filename
    unique_name = f"{uuid.uuid4()}_{req.filename}"
    pathname = f"{req.entity_type}/{req.entity_id}/{unique_name}"
    
    # Check S3 configuration
    if not settings.S3_ENDPOINT_URL:
        raise HTTPException(503, "Media upload temporarily unavailable. S3 storage not configured.")

    try:
        import boto3
        s3 = boto3.client(
            's3',
            endpoint_url=settings.S3_ENDPOINT_URL,
            aws_access_key_id=settings.S3_ACCESS_KEY,
            aws_secret_access_key=settings.S3_SECRET_KEY,
        )
        
        # Generate presigned URL for PUT
        upload_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': settings.S3_BUCKET_NAME,
                'Key': pathname,
                'ContentType': req.content_type,
            },
            ExpiresIn=900  # 15 minutes
        )
        
        # If S3_PUBLIC_URL is set, replace internal endpoint with public URL in presigned URL
        # This is needed when MinIO runs on localhost but needs to be accessed from browser
        if settings.S3_PUBLIC_URL and settings.S3_ENDPOINT_URL:
            # Extract base URL from S3_PUBLIC_URL (e.g., http://82.202.159.64:9000/audiogid -> http://82.202.159.64:9000)
            public_base = settings.S3_PUBLIC_URL.rstrip('/')
            if f"/{settings.S3_BUCKET_NAME}" in public_base:
                public_base = public_base.rsplit(f"/{settings.S3_BUCKET_NAME}", 1)[0]
            upload_url = upload_url.replace(settings.S3_ENDPOINT_URL.rstrip('/'), public_base)
        
        # Public URL for accessing the file
        if settings.S3_PUBLIC_URL:
            final_url = f"{settings.S3_PUBLIC_URL.rstrip('/')}/{pathname}"
        else:
            final_url = f"{settings.S3_ENDPOINT_URL.rstrip('/')}/{settings.S3_BUCKET_NAME}/{pathname}"
        
        return {
            "upload_url": upload_url,
            "final_url": final_url,
            "method": "PUT",
            "headers": {"Content-Type": req.content_type},
            "expires_at": datetime.utcnow() + timedelta(minutes=15)
        }
    except ImportError:
        raise HTTPException(503, "boto3 not installed. S3 storage unavailable.")
    except Exception as e:
        import logging
        logging.getLogger(__name__).error(f"S3 Presign Error: {e}")
        raise HTTPException(502, f"Failed to generate upload URL: {str(e)}")

@router.get("/admin/pois/{poi_id}/publish_check", response_model=PublishCheckResult)
def check_poi_publish_status(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
     user: User = Depends(require_permission('poi:read'))
):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    
    issues = []
    if not poi.description_ru or len(poi.description_ru) < 10:
        issues.append("Description too short")
    if poi.lat is None or poi.lon is None:
        issues.append("Coordinates missing")
    
    return {"can_publish": len(issues) == 0, "issues": issues}
        

# --- AI / Tools ---

class ImportWikipediaReq(BaseModel):
    query: str
    lang: str = "ru"

@router.post("/admin/pois/{poi_id}/import-wikipedia")
async def import_wikipedia(
    poi_id: uuid.UUID,
    req: ImportWikipediaReq,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('poi:write'))
):
    import httpx
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")

    # Clean query (extract title from URL if needed)
    search_term = req.query
    if "wikipedia.org/wiki/" in search_term:
        search_term = search_term.split("wiki/")[-1].replace("_", " ")

    api_url = f"https://{req.lang}.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "format": "json",
        "prop": "extracts|coordinates|pageimages|info",
        "inprop": "url",
        "pithumbsize": 1000,
        "titles": search_term,
        "explaintext": 1,
        "exintro": 1
    }

    async with httpx.AsyncClient() as client:
        resp = await client.get(api_url, params=params)
        data = resp.json()

    pages = data.get("query", {}).get("pages", {})
    if not pages or "-1" in pages:
        raise HTTPException(404, "Wikipedia page not found")

    page = list(pages.values())[0]

    # Update POI fields
    changes = []
    
    if req.lang == "ru":
        if not poi.title_ru or True: # Always update? Maybe user wants to fetch.
             poi.title_ru = page.get("title")
             changes.append("title_ru")
        if not poi.description_ru:
             poi.description_ru = page.get("extract")
             changes.append("description_ru")
             
    # Coordinates
    if "coordinates" in page and not poi.lat:
        coords = page["coordinates"][0]
        poi.lat = coords["lat"]
        poi.lon = coords["lon"]
        poi.geo = WKTElement(f"POINT({poi.lon} {poi.lat})", srid=4326)
        changes.append("geo")

    # Cover Image
    if "thumbnail" in page and not poi.cover_image:
        poi.cover_image = page["thumbnail"]["source"]
        changes.append("cover_image")

    # Source
    if "fullurl" in page:
        # Check if source exists
        exists = session.exec(select(PoiSource).where(PoiSource.poi_id == poi_id, PoiSource.url == page["fullurl"])).first()
        if not exists:
            src = PoiSource(poi_id=poi_id, name="Wikipedia", url=page["fullurl"])
            session.add(src)
            changes.append("source_added")

    session.add(poi)
    session.add(AppEvent(event_type="poi_wiki_import", user_id=user.id, payload_json=json.dumps({"id": str(poi.id), "term": search_term})))
    session.commit()
    session.refresh(poi)
    

@router.post("/admin/pois/{poi_id}/generate-tts")
async def generate_tts(
    poi_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('poi:write'))
):
    poi = session.get(Poi, poi_id)
    if not poi: raise HTTPException(404, "POI not found")
    
    if not poi.description_ru: raise HTTPException(400, "Description (RU) is mandatory for TTS.")
    
    # Enqueue Job
    payload = json.dumps({
        "poi_id": str(poi.id),
        "text": poi.description_ru,
        "locale": "ru",
        "voice": "onyx"
    })
    
    try:
        job = await enqueue_job("generate_narration", payload, session)
    except Exception as e:
        raise HTTPException(500, f"Failed to queue TTS job: {e}")
        
    return {"status": "queued", "job_id": job.id}
