import hashlib
from typing import Any, Type, Optional
from fastapi import Request, Response, HTTPException
from sqlmodel import Session, select, func
from datetime import datetime

SCHEMA_VERSION = "v1"

def generate_version_marker(session: Session, model: Any, city_slug: Optional[str] = None) -> str:
    """
    Generate a cheap version marker from DB.
    Marker = MAX(updated_at) + COUNT(*) + city_slug + schema_version.
    """
    # 1. Base Query
    query = select(func.max(model.updated_at), func.count(model.id))
    
    # 2. Add City Filter if applicable
    if city_slug and hasattr(model, "city_slug"):
        query = query.where(model.city_slug == city_slug)
    elif city_slug and hasattr(model, "slug"):
        query = query.where(model.slug == city_slug)
        
    result = session.exec(query).first()
    max_updated, count = result if result else (None, 0)
    
    # 3. Deterministic hash of the marker
    marker_str = f"{SCHEMA_VERSION}|{city_slug}|{max_updated}|{count}"
    hash_val = hashlib.sha256(marker_str.encode("utf-8")).hexdigest()
    
    return f'W/"{hash_val[:16]}"'

def check_etag_versioned(request: Request, response: Response, etag: str, is_public: bool = True):
    """
    Check ETag and raise 304 if match.
    Sets Cache-Control based on visibility.
    """
    # Public: CDN cached, stale-while-revalidate for high performance
    if is_public:
        cache_control = "public, max-age=60, s-maxage=3600, stale-while-revalidate=86400"
    else:
        # Private: Entitlement gated content must not be cached by shared caches
        cache_control = "private, no-store"
        response.headers["Vary"] = "Authorization, X-Admin-Token"
        
    if_none_match = request.headers.get("if-none-match")

    
    if if_none_match == etag:
        raise HTTPException(
            status_code=304,
            headers={"ETag": etag, "Cache-Control": cache_control}
        )
        
    response.headers["ETag"] = etag
    response.headers["Cache-Control"] = cache_control
