from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
import uuid
import logging
import io
from ..core.config import config
from ..auth.deps import get_current_user, get_session
from ..core.models import User, PoiMedia, TourMedia
from sqlmodel import Session, select, func

router = APIRouter()
logger = logging.getLogger(__name__)

# --- Media List Endpoint ---
class MediaItem(BaseModel):
    id: str
    url: str
    media_type: Optional[str] = None
    entity_type: str  # 'poi' or 'tour'
    entity_id: str
    entity_title: Optional[str] = None
    license_type: Optional[str] = None
    author: Optional[str] = None

class MediaListResponse(BaseModel):
    items: List[MediaItem]
    total: int
    page: int
    per_page: int
    pages: int

@router.get("/admin/media", response_model=MediaListResponse)
def list_media(
    page: int = Query(1, ge=1),
    per_page: int = Query(24, ge=1, le=100),
    type: Optional[str] = Query(None, alias="type"),  # frontend sends 'type'
    media_type: Optional[str] = Query(None),  # also accept media_type
    entity_type: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    session: Session = Depends(get_session),
    user: User = Depends(get_current_user)
):
    """List all media from POIs and Tours"""
    items = []
    
    # Use 'type' if provided, otherwise use 'media_type'
    filter_type = type or media_type
    
    # Get POI media
    poi_media_query = select(PoiMedia)
    poi_media = session.exec(poi_media_query).all()
    for m in poi_media:
        # Filter by media type
        if filter_type and filter_type != 'all' and m.media_type != filter_type:
            continue
        # Filter by entity type
        if entity_type and entity_type != 'all' and entity_type != 'poi':
            continue
        # Filter by search (author or url)
        if search:
            search_lower = search.lower()
            author_match = m.author and search_lower in m.author.lower()
            url_match = m.url and search_lower in m.url.lower()
            if not (author_match or url_match):
                continue
        items.append(MediaItem(
            id=str(m.id),
            url=m.url,
            media_type=m.media_type,
            entity_type='poi',
            entity_id=str(m.poi_id),
            license_type=m.license_type,
            author=m.author
        ))
    
    # Get Tour media (skip if entity_type filter is 'poi')
    if not entity_type or entity_type == 'all' or entity_type == 'tour':
        tour_media_query = select(TourMedia)
        tour_media = session.exec(tour_media_query).all()
        for m in tour_media:
            # Filter by media type
            if filter_type and filter_type != 'all' and m.media_type != filter_type:
                continue
            # Filter by search (author or url)
            if search:
                search_lower = search.lower()
                author_match = m.author and search_lower in m.author.lower()
                url_match = m.url and search_lower in m.url.lower()
                if not (author_match or url_match):
                    continue
            items.append(MediaItem(
                id=str(m.id),
                url=m.url,
                media_type=m.media_type,
                entity_type='tour',
                entity_id=str(m.tour_id),
                license_type=m.license_type,
                author=m.author
            ))
    
    total = len(items)
    pages = (total + per_page - 1) // per_page if total > 0 else 1
    start = (page - 1) * per_page
    end = start + per_page
    paginated_items = items[start:end]
    
    return MediaListResponse(
        items=paginated_items,
        total=total,
        page=page,
        per_page=per_page,
        pages=pages
    )

# S3-compatible storage client (MinIO, Yandex Object Storage, etc.)
_s3_client = None

def get_s3_client():
    global _s3_client
    if _s3_client is None:
        if not config.S3_ENDPOINT_URL:
            return None
        try:
            import boto3
            _s3_client = boto3.client(
                's3',
                endpoint_url=config.S3_ENDPOINT_URL,
                aws_access_key_id=config.S3_ACCESS_KEY,
                aws_secret_access_key=config.S3_SECRET_KEY,
            )
        except ImportError:
            logger.error("boto3 not installed, S3 storage unavailable")
            return None
    return _s3_client

class PresignRequest(BaseModel):
    filename: str
    content_type: str
    entity_type: str | None = None
    entity_id: str | None = None

class PresignResponse(BaseModel):
    upload_url: str
    final_url: str
    access: str = "public" 

def require_admin(user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(403, "Admin access required")
    return user

@router.post("/media/presign")
async def presign_media_upload(
    req: PresignRequest,
    user: User = Depends(require_admin)
) -> PresignResponse:
    """
    Generate presigned URL for S3-compatible storage upload (MinIO, Yandex Object Storage, etc.)
    """
    s3 = get_s3_client()
    if not s3:
        raise HTTPException(500, "Storage configuration missing. Set S3_ENDPOINT_URL, S3_ACCESS_KEY, S3_SECRET_KEY")

    path_prefix = "uploads"
    if req.entity_type:
        path_prefix = req.entity_type
    
    object_key = f"{path_prefix}/{uuid.uuid4()}-{req.filename}"

    try:
        # Generate presigned URL for PUT operation
        upload_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': config.S3_BUCKET_NAME,
                'Key': object_key,
                'ContentType': req.content_type,
            },
            ExpiresIn=3600  # 1 hour
        )
        
        # If S3_PUBLIC_URL is set, replace internal endpoint with public URL in presigned URL
        # This is needed when MinIO runs on localhost but needs to be accessed from browser
        if config.S3_PUBLIC_URL and config.S3_ENDPOINT_URL:
            # Extract base URL from S3_PUBLIC_URL (e.g., http://82.202.159.64:9000/audiogid -> http://82.202.159.64:9000)
            public_base = config.S3_PUBLIC_URL.rstrip('/')
            if f"/{config.S3_BUCKET_NAME}" in public_base:
                public_base = public_base.rsplit(f"/{config.S3_BUCKET_NAME}", 1)[0]
            upload_url = upload_url.replace(config.S3_ENDPOINT_URL.rstrip('/'), public_base)
        
        # Public URL for accessing the file after upload
        if config.S3_PUBLIC_URL:
            final_url = f"{config.S3_PUBLIC_URL.rstrip('/')}/{object_key}"
        else:
            final_url = f"{config.S3_ENDPOINT_URL.rstrip('/')}/{config.S3_BUCKET_NAME}/{object_key}"
        
        return PresignResponse(
            upload_url=upload_url,
            final_url=final_url
        )
    except Exception as e:
        logger.error(f"Presign Exception: {e}")
        raise HTTPException(500, str(e))


class UploadResponse(BaseModel):
    url: str
    filename: str
    size: int


@router.post("/admin/media/upload", response_model=UploadResponse)
async def upload_media_file(
    file: UploadFile = File(...),
    entity_type: str = Form(default="uploads"),
    entity_id: str = Form(default=None),
    user: User = Depends(require_admin)
):
    """
    Direct file upload to S3-compatible storage.
    Use this when presigned URLs don't work (e.g., CORS issues).
    
    Supported entity_types: tours, pois, cities, uploads
    """
    s3 = get_s3_client()
    if not s3:
        raise HTTPException(500, "Storage not configured. Set S3_ENDPOINT_URL, S3_ACCESS_KEY, S3_SECRET_KEY")
    
    # Validate file type - images and audio
    allowed_types = [
        'image/jpeg', 'image/png', 'image/webp', 'image/gif',
        'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/ogg'
    ]
    if file.content_type not in allowed_types:
        raise HTTPException(400, f"Invalid file type: {file.content_type}. Allowed: {allowed_types}")
    
    # Limit file size (50MB for audio, 10MB for images)
    is_audio = file.content_type.startswith('audio/')
    max_size = 50 * 1024 * 1024 if is_audio else 10 * 1024 * 1024
    contents = await file.read()
    if len(contents) > max_size:
        raise HTTPException(400, f"File too large. Max size: {max_size // 1024 // 1024}MB")
    
    # Generate object key
    ext = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
    if entity_id:
        object_key = f"{entity_type}/{entity_id}/{uuid.uuid4()}.{ext}"
    else:
        object_key = f"{entity_type}/{uuid.uuid4()}.{ext}"
    
    try:
        # Upload to S3
        s3.upload_fileobj(
            io.BytesIO(contents),
            config.S3_BUCKET_NAME,
            object_key,
            ExtraArgs={
                'ContentType': file.content_type,
                'ACL': 'public-read'
            }
        )
        
        # Generate public URL
        if config.S3_PUBLIC_URL:
            final_url = f"{config.S3_PUBLIC_URL.rstrip('/')}/{object_key}"
        else:
            final_url = f"{config.S3_ENDPOINT_URL.rstrip('/')}/{config.S3_BUCKET_NAME}/{object_key}"
        
        logger.info(f"Uploaded {file.filename} to {final_url} by user {user.id}")
        
        return UploadResponse(
            url=final_url,
            filename=object_key,
            size=len(contents)
        )
    except Exception as e:
        logger.error(f"Upload Exception: {e}")
        raise HTTPException(500, f"Upload failed: {str(e)}")
