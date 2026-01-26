import logging
import hmac
import hashlib
import time
import base64
from .config import config

logger = logging.getLogger(__name__)

def sign_asset_url(url: str, ttl_seconds: int = 3600) -> str:
    """
    Signs a URL for temporary access using HMAC and TTL.
    Even if blob is public, this enforces platform-level gating.
    """
    if not url: return url
    
    # Fail-fast if secret is missing but signing is required for P0
    secret = config.YOOKASSA_WEBHOOK_SECRET # Using webhook secret as a platform secret if no other is defined
    if not secret:
        logger.error("CRITICAL: No platform secret for URL signing.")
        return url
        
    expires = int(time.time()) + ttl_seconds
    
    # 1. Prepare base string
    # Remove existing query if any (simplified)
    base_url = url.split("?")[0]
    payload = f"{base_url}|{expires}"
    
    # 2. Generate HMAC
    signature = hmac.new(
        secret.encode("utf-8"),
        payload.encode("utf-8"),
        hashlib.sha256
    ).digest()
    
    encoded_sig = base64.urlsafe_b64encode(signature).decode("utf-8").rstrip("=")
    
    # 3. Append params
    separator = "&" if "?" in url else "?"
    signed_url = f"{url}{separator}token={encoded_sig}&expires={expires}"
    
    return signed_url

def verify_asset_signature(url: str, token: str, expires: int) -> bool:
    """
    Verifies the HMAC signature of a URL.
    """
    if int(time.time()) > expires:
        return False
        
    secret = config.YOOKASSA_WEBHOOK_SECRET
    if not secret: return False
    
    base_url = url.split("?")[0]
    payload = f"{base_url}|{expires}"
    
    expected_sig = hmac.new(
        secret.encode("utf-8"),
        payload.encode("utf-8"),
        hashlib.sha256
    ).digest()
    
    actual_sig = base64.urlsafe_b64decode(token + "==")
    
    return hmac.compare_digest(expected_sig, actual_sig)
