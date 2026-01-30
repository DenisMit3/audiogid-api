from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import time
from collections import defaultdict
import logging
from .config import config

logger = logging.getLogger("api.ratelimit")

# In-memory store (Fallback / Development)
_rate_limit_store = defaultdict(list)

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.default_limit = 100 
        self.redis = None
        if config.REDIS_URL:
            try:
                import redis.asyncio as redis
                self.redis = redis.from_url(config.REDIS_URL, decode_responses=True)
                # Async connection check would require await, skipping in __init__
                logger.info("Redis Rate Limiting connected (Async).")
            except (ImportError, Exception) as e:
                logger.warning(f"Redis rate limiting unavailable ({e}), falling back to in-memory.")
                self.redis = None

    async def dispatch(self, request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        path = request.url.path
        
        # Determine limit based on path (requests per minute)
        limit = self.default_limit
        if path.startswith("/v1/public"):
             limit = 60 
        elif path.startswith("/v1/auth"):
             limit = 20
        elif path.startswith("/v1/admin"):
             limit = 300
        elif path.startswith("/v1/ops"):
             limit = 1000

        now = time.time()
        
        if self.redis:
            try:
                # Key based on IP and major path groups
                prefix = path.split("/")[2] if len(path.split("/")) > 2 else "root"
                key = f"ratelimit:{client_ip}:{prefix}"
                
                async with self.redis.pipeline() as pipe:
                    pipe.zadd(key, {str(now): now})
                    pipe.zremrangebyscore(key, 0, now - 60)
                    pipe.zcard(key)
                    pipe.expire(key, 120) # Keep for a bit longer than the window
                    results = await pipe.execute()
                
                current_count = results[2]
                
                if current_count > limit:
                    return JSONResponse(
                        {"error": "Too many requests", "detail": "Rate limit exceeded (Global)"}, 
                        status_code=429
                    )
                
                return await call_next(request)
            except Exception as e:
                logger.error(f"Redis Rate Limit operation failed: {e}")
                # Fallback to server-local memory

        # Prune old timestamps (In-memory fallback)
        timestamps = _rate_limit_store[client_ip]
        timestamps = [t for t in timestamps if now - t < 60]
        _rate_limit_store[client_ip] = timestamps
        
        if len(timestamps) >= limit:
            return JSONResponse(
                {"error": "Too many requests", "detail": "Rate limit exceeded (Local)"}, 
                status_code=429
            )
            
        timestamps.append(now)
        return await call_next(request)

