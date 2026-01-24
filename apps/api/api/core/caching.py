import hashlib
import json
from typing import Any
from fastapi import Request, Response, HTTPException

def generate_etag(content: Any, context: str = "") -> str:
    """
    Generate Weak ETag (W/...) for JSON content.
    Includes 'context' (e.g. query params) to ensure scope uniqueness.
    """
    # Deterministic JSON serialization
    json_str = json.dumps(content, sort_keys=True, default=str)
    
    # Mix in context to bind ETag to the specific resource variant/query
    payload = f"{context}|{json_str}"
    
    hash_val = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    return f'W/"{hash_val}"'

def check_etag(request: Request, response: Response, content: Any):
    """
    Manual ETag check.
    Uses Request Query Params as context scope.
    Sets Cache-Control: public, max-age=60.
    """
    # Use query string as context scope
    context = str(request.query_params)
    etag = generate_etag(content, context)
    
    # Cache Policy: Public (CDN friendly), 1 minute freshness before revalidation
    cache_control = "public, max-age=60"
    
    if_none_match = request.headers.get("if-none-match")
    
    # 304 Logic
    if if_none_match == etag:
        raise HTTPException(
            status_code=304,
            headers={"ETag": etag, "Cache-Control": cache_control}
        )
        
    # Set headers for 200 OK
    response.headers["ETag"] = etag
    response.headers["Cache-Control"] = cache_control
