import logging
import time
import sys
import json
from typing import Callable, Any
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp

logger = logging.getLogger("api.access")

# Sensitive headers to redact
SENSITIVE_HEADERS = {"authorization", "x-admin-token", "cookie", "set-cookie", "proof", "deletion-token"}

class SecurityMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Callable[[Request], Any]) -> Response:
        start_time = time.time()
        
        # 1. Payload Size Cap (Basic Content-Length check)
        content_length = request.headers.get("content-length")
        if content_length and int(content_length) > 1_000_000: # 1MB limit
            return Response("Payload Too Large", status_code=413)

        response = await call_next(request)
        process_time = (time.time() - start_time) * 1000

        # 2. Security Headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains; preload"
        # X-Frame-Options: DENY (unless we need iframe embedding, presumably no)
        response.headers["X-Frame-Options"] = "DENY"

        # 3. Cache-Control Constraints for Sensitive Paths
        path = request.url.path
        if any(x in path for x in ["/manifest", "/delete", "/purchases", "/entitlements"]):
             response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"

        # 4. Structured Logging (Access Log)
        log_entry = {
            "path": request.url.path,
            "method": request.method,
            "status": response.status_code,
            "duration_ms": round(process_time, 2),
            "ip": request.client.host if request.client else "unknown",
            "trace_id": request.headers.get("x-request-id", "unknown")
        }
        
        # Redact query params if sensitive?
        # For MVP we trust path logging is okay, query params might contain PII only if badly designed.
        # Our API puts PII in Body or Headers mostly.
        
        # Log level based on status
        if response.status_code >= 500:
            logger.error("Request Failed", extra=log_entry)
        elif response.status_code >= 400:
            logger.warning("Request Error", extra=log_entry)
        else:
            logger.info("Request Processed", extra=log_entry)

        return response
