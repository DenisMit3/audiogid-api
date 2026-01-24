import logging
import uuid
import time
from fastapi import Request

async def structured_logging_middleware(request: Request, call_next):
    trace_id = request.headers.get("X-Trace-Id", str(uuid.uuid4()))
    start_time = time.time()
    
    # Contextual logging logic would go here
    # For now, we ensure headers are propagated
    response = await call_next(request)
    
    process_time = time.time() - start_time
    
    # JSON log format simulated
    log_entry = {
        "trace_id": trace_id,
        "method": request.method,
        "path": request.url.path,
        "status_code": response.status_code,
        "duration_ms": round(process_time * 1000, 2)
    }
    # In real prod, use json.dumps and logger
    if response.status_code >= 400:
        print(f"ERROR: {log_entry}")
    else:
        print(f"INFO: {log_entry}")
        
    response.headers["X-Trace-Id"] = trace_id
    return response
