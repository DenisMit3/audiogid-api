#!/bin/bash
# Quick update script for Audiogid API
# Run this on Cloud.ru server to enable direct file upload

set -e

API_DIR=/opt/audiogid/api

echo "=== Updating Audiogid API ==="

# Backup current version
if [ -f "$API_DIR/api/admin/media.py" ]; then
    cp "$API_DIR/api/admin/media.py" "$API_DIR/api/admin/media.py.backup"
fi

# Download updated media.py from GitHub or paste content
cat > "$API_DIR/api/admin/media.py" << 'MEDIA_PY'
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uuid
import logging
import io

router = APIRouter()
logger = logging.getLogger(__name__)

# Import config - try different paths
try:
    from ..core.config import config
    settings = config
except:
    try:
        from api.core.config import settings
    except:
        settings = None

# Import auth
try:
    from ..auth.deps import get_current_user
    from ..core.models import User
except:
    from api.auth.deps import get_current_user
    from api.core.models import User

_s3_client = None

def get_s3_client():
    global _s3_client
    if _s3_client is None:
        endpoint = getattr(settings, 'S3_ENDPOINT_URL', None) if settings else None
        if not endpoint:
            return None
        try:
            import boto3
            _s3_client = boto3.client(
                's3',
                endpoint_url=endpoint,
                aws_access_key_id=getattr(settings, 'S3_ACCESS_KEY', 'minioadmin'),
                aws_secret_access_key=getattr(settings, 'S3_SECRET_KEY', 'minioadmin'),
            )
        except ImportError:
            logger.error("boto3 not installed")
            return None
    return _s3_client

def require_admin(user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(403, "Admin access required")
    return user

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
    """Direct file upload to S3-compatible storage."""
    s3 = get_s3_client()
    if not s3:
        raise HTTPException(500, "Storage not configured")
    
    bucket = getattr(settings, 'S3_BUCKET_NAME', 'audiogid')
    public_url = getattr(settings, 'S3_PUBLIC_URL', None)
    endpoint_url = getattr(settings, 'S3_ENDPOINT_URL', 'http://localhost:9000')
    
    allowed_types = [
        'image/jpeg', 'image/png', 'image/webp', 'image/gif',
        'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/ogg'
    ]
    if file.content_type not in allowed_types:
        raise HTTPException(400, f"Invalid file type: {file.content_type}")
    
    is_audio = file.content_type.startswith('audio/')
    max_size = 50 * 1024 * 1024 if is_audio else 10 * 1024 * 1024
    contents = await file.read()
    if len(contents) > max_size:
        raise HTTPException(400, f"File too large. Max: {max_size // 1024 // 1024}MB")
    
    ext = file.filename.split('.')[-1] if '.' in file.filename else 'bin'
    if entity_id:
        object_key = f"{entity_type}/{entity_id}/{uuid.uuid4()}.{ext}"
    else:
        object_key = f"{entity_type}/{uuid.uuid4()}.{ext}"
    
    try:
        s3.upload_fileobj(
            io.BytesIO(contents),
            bucket,
            object_key,
            ExtraArgs={'ContentType': file.content_type, 'ACL': 'public-read'}
        )
        
        if public_url:
            final_url = f"{public_url.rstrip('/')}/{object_key}"
        else:
            final_url = f"{endpoint_url.rstrip('/')}/{bucket}/{object_key}"
        
        logger.info(f"Uploaded {file.filename} to {final_url}")
        return UploadResponse(url=final_url, filename=object_key, size=len(contents))
    except Exception as e:
        logger.error(f"Upload failed: {e}")
        raise HTTPException(500, f"Upload failed: {str(e)}")
MEDIA_PY

# Restart API service
echo "Restarting API service..."
sudo systemctl restart audiogid-api || sudo systemctl restart audiogid || echo "Service restart failed, try manually"

echo ""
echo "=== Update Complete ==="
echo "Test with: curl -X POST http://localhost:8000/v1/admin/media/upload"
