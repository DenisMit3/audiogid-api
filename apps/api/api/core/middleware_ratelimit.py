from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import time
from collections import defaultdict

_rate_limit_store = defaultdict(list)

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.default_limit = 100 

    async def dispatch(self, request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        path = request.url.path
        
        # Determine limit based on path
        limit = self.default_limit
        if path.startswith("/v1/public"):
             limit = 60 # 1 per sec
        elif path.startswith("/v1/auth"):
             limit = 20 # Protect auth
        elif path.startswith("/v1/admin"):
             limit = 300 # Higher for admin
        elif path.startswith("/v1/ops"):
             limit = 1000 # High for ops/health

        # Prune old timestamps
        now = time.time()
        timestamps = _rate_limit_store[client_ip]
        timestamps = [t for t in timestamps if now - t < 60]
        _rate_limit_store[client_ip] = timestamps
        
        if len(timestamps) >= limit:
            return JSONResponse({"error": "Too many requests", "detail": "Rate limit exceeded"}, status_code=429)
            
        timestamps.append(now)
        return await call_next(request)
