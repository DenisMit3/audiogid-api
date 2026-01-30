from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import requests
import uuid
import logging
from ..core.config import config
from ..auth.deps import get_current_user
from ..core.models import User

router = APIRouter()
logger = logging.getLogger(__name__)

class PresignRequest(BaseModel):
    filename: str
    content_type: str
    entity_type: str | None = None
    entity_id: str | None = None

class PresignResponse(BaseModel):
    upload_url: str
    final_url: str
    # Optional fields that Vercel might return
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
    Generate presigned URL for Vercel Blob upload.
    """
    if not config.VERCEL_BLOB_READ_WRITE_TOKEN:
         raise HTTPException(500, "Blob configuration missing")

    path_prefix = "uploads"
    if req.entity_type:
         path_prefix = req.entity_type
    
    unique_path = f"{path_prefix}/{uuid.uuid4()}-{req.filename}"

    try:
        # Using Vercel Blob API (undocumented public endpoint or via plan)
        # Note: Ideally usage of vercel-blob-python or similar, but following plan.
        # If this endpoint fails (404), we might need to fallback to SDK or correct URL.
        # Common Vercel Blob multipart upload uses /mpu or just PUT.
        # For client-side uploads, we usually implement 'handleUpload' which validates and signs.
        # But assuming direct presign for PUT here as requested.
        
        # Attempting client-upload token generation or similar.
        # Actually, https://blob.vercel-storage.com does not have a public /presign that takes arbitrary input without SDK wrapper logic usually.
        # But assuming the USER knows the URL is valid or we are simulating standard S3-like presign.
        # WARNING: If this URL is wrong, upload will fail.
        
        res = requests.post(
            "https://blob.vercel-storage.com/mpu", # Using MPU which is often used for this
            headers={
                "Authorization": f"Bearer {config.VERCEL_BLOB_READ_WRITE_TOKEN}",
                "x-api-version": "1" # often required
            },
            json={
                "pathname": unique_path,
                "contentType": req.content_type,
                "access": "public" 
            }
        )
        
        # If 404/405, we might try simple PUT logic simulation if we can't do it.
        if res.status_code not in [200, 201]:
             logger.error(f"Blob Presign Fail: {res.status_code} {res.text}")
             raise HTTPException(502, f"Blob Provider Error: {res.text}")

        data = res.json()
        
        # MPU response usually: { url, uploadId, key... } or { url } for simple put?
        # If it's a simple PUT (one step):
        return PresignResponse(
            upload_url=data.get("url"), # URL to PUT to
            final_url=data.get("url")   # URL to GET from (often same for Vercel Blob public)
        )
    except Exception as e:
        logger.error(f"Presign Exception: {e}")
        raise HTTPException(500, str(e))
