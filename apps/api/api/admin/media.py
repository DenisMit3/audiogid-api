from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import uuid
import logging
from ..core.config import config
from ..auth.deps import get_current_user
from ..core.models import User

router = APIRouter()
logger = logging.getLogger(__name__)

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
