
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, text
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
import uuid

from ..core.database import engine
from ..core.models import AuditLog, User
from ..auth.deps import get_session, require_permission

router = APIRouter()

class AuditLogRead(BaseModel):
    id: uuid.UUID
    action: str
    target_id: uuid.UUID
    actor_fingerprint: str
    timestamp: datetime
    ip_address: Optional[str]
    user_agent: Optional[str]
    diff_json: Optional[str]

@router.get("/admin/audit/logs", response_model=List[AuditLogRead])
def list_audit_logs(
    offset: int = 0,
    limit: int = 50,
    action: Optional[str] = None,
    target_id: Optional[str] = None,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('audit:read'))
):
    query = select(AuditLog).order_by(AuditLog.timestamp.desc())
    
    if action:
        query = query.where(AuditLog.action == action)
    if target_id:
        try:
            uid = uuid.UUID(target_id)
            query = query.where(AuditLog.target_id == uid)
        except: pass
        
    query = query.offset(offset).limit(limit)
    return session.exec(query).all()

@router.get("/admin/audit/logs/{log_id}", response_model=AuditLogRead)
def get_audit_log(
    log_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('audit:read'))
):
    log = session.get(AuditLog, log_id)
    if not log:
        raise HTTPException(404, "Log not found")
    return log
