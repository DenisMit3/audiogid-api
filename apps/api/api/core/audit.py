
from functools import wraps
from typing import Callable, Any, Optional
import json
from datetime import datetime
from threading import local
from fastapi import Request

from sqlmodel import Session
from .models import AuditLog, User
from .database import engine

# Context-local storage to capture request/user info if needed inside service methods
_audit_context = local()

def set_audit_context(request: Request, user: Optional[User]):
    _audit_context.request = request
    _audit_context.user = user

def clear_audit_context():
    if hasattr(_audit_context, 'request'): del _audit_context.request
    if hasattr(_audit_context, 'user'): del _audit_context.user

def audit_log(action: str):
    """
    Decorator for API route handlers or service methods.
    Captures Before/After state if possible (requires 'session' arg).
    """
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Try to find session and target_id
            session: Optional[Session] = None
            for arg in args:
                if isinstance(arg, Session):
                    session = arg
                    break
            if not session and 'session' in kwargs:
                session = kwargs['session']
                
            # If no session, we can't easily query DB/audit, but we can try to proceed
            
            # Logic: 
            # 1. Inspect kwargs for entity ID (e.g. poi_id, user_id)
            # 2. Allow function to execute
            # 3. Log result
            
            # Capture context
            request = getattr(_audit_context, 'request', None)
            user = getattr(_audit_context, 'user', None)
            
            # Helper to extract ID
            target_id = None
            for k, v in kwargs.items():
                if k.endswith('_id') and v:
                    try:
                        import uuid
                        if isinstance(v, uuid.UUID) or (isinstance(v, str) and len(v) == 36):
                            target_id = str(v)
                            break
                    except: pass
            
            # Execute
            try:
                result = func(*args, **kwargs)
            except Exception as e:
                raise e
            
            # Post-execution logging
            if session and target_id and user:
                try:
                    # Construct diff? Complex without "before" snapshot.
                    # For MVP, just log the action payload.
                    # If kwargs has Pydantic model (e.g. 'params'), serialize it
                    payload = {}
                    for k, v in kwargs.items():
                        if hasattr(v, 'dict'):
                            payload[k] = v.dict()
                    
                    ip = request.client.host if request else None
                    ua = request.headers.get('user-agent') if request else None
                    
                    log = AuditLog(
                        action=action,
                        target_id=target_id,
                        actor_type="user",
                        actor_fingerprint=str(user.id),
                        ip_address=ip,
                        user_agent=ua,
                        diff_json=json.dumps(payload, default=str)
                    )
                    session.add(log)
                    # We rely on main transaction commit usually, or commit here if independent?
                    # Ideally independent, but session is shared. 
                    # If endpoint commits, this adds to it.
                    session.add(log)
                except Exception as log_err:
                    print(f"Audit log failed: {log_err}")
                    
            return result
        return wrapper
    return decorator
