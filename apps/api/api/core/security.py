import logging
# Placeholder for future signed URL logic (S3/Blob Token)
# currently pass-through for public Vercel Blob

logger = logging.getLogger(__name__)

def sign_asset_url(url: str, ttl_seconds: int = 3600) -> str:
    """
    Signs a URL for temporary access.
    
    Current implementation:
    - Vercel Blob (public): Returns as-is.
    - Future: Generate SAS/Presigned URL for S3/Private Blob.
    """
    # TODO: Implement Vercel Blob Token generation if/when moving to Private Access
    return url
