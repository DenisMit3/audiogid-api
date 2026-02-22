
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import asyncio

class TimeoutMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, timeout: int = 120):  # 2 min for Neon cold start
        super().__init__(app)
        self.timeout = timeout

    async def dispatch(self, request, call_next):
        try:
            return await asyncio.wait_for(call_next(request), timeout=self.timeout)
        except asyncio.TimeoutError:
            return JSONResponse({"error": "Request timed out"}, status_code=504)
