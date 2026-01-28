
# In a real scenario, we would use SlowAPI here.
# Since I cannot easily install packages in this environment without risk,
# I will create a placeholder Middleware that mocks rate limiting or uses simple in-memory logic.

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import time
from collections import defaultdict

# Simple In-Memory Rate Limiting (Single Worker)
# For production with multiple workers, reuse Redis or similar.
_rate_limit_store = defaultdict(list)

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, requests_per_minute: int = 100):
        super().__init__(app)
        self.limit = requests_per_minute

    async def dispatch(self, request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        
        # Prune old timestamps
        now = time.time()
        # Key: IP
        timestamps = _rate_limit_store[client_ip]
        # Remove timestamps older than 60s
        timestamps = [t for t in timestamps if now - t < 60]
        _rate_limit_store[client_ip] = timestamps
        
        if len(timestamps) >= self.limit:
            return JSONResponse({"error": "Too many requests"}, status_code=429)
            
        timestamps.append(now)
        # Store back (unnecessary for list ref, but clean)
        
        return await call_next(request)
