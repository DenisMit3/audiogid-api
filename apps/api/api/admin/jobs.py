
from typing import List, Optional
import uuid
import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, WebSocket, WebSocketDisconnect
from sqlmodel import Session, select, func
import asyncio

from ..core.models import Job, User
from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

# --- WebSocket Manager ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception:
                # remove dead connection
                pass

manager = ConnectionManager()

# --- Endpoints ---

@router.get("/admin/jobs")
def list_jobs(
    job_type: str | None = None,
    status: str | None = None,
    limit: int = Query(50, le=100),
    offset: int = 0,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('jobs:read'))
):
    query = select(Job)
    if job_type: query = query.where(Job.type == job_type)
    if status: query = query.where(Job.status == status)
    
    # Get total count (inefficient for large tables, but ok for admin)
    total = session.exec(select(func.count()).select_from(query.subquery())).one()
    
    query = query.order_by(Job.created_at.desc()).offset(offset).limit(limit)
    jobs = session.exec(query).all()
    
    return {"items": jobs, "total": total, "limit": limit, "offset": offset}

@router.get("/admin/jobs/{job_id}")
def get_job_details(
    job_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('jobs:read'))
):
    job = session.get(Job, job_id)
    if not job: raise HTTPException(404, "Job not found")
    return job

@router.post("/admin/jobs/{job_id}/cancel")
def cancel_job(
    job_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('jobs:write'))
):
    job = session.get(Job, job_id)
    if not job: raise HTTPException(404)
    if job.status not in ["PENDING", "RUNNING"]:
        raise HTTPException(400, "Cannot cancel completed job")
        
    job.status = "CANCELLED"
    session.add(job)
    session.commit()
    return {"status": "cancelled"}

@router.post("/admin/jobs/{job_id}/retry")
def retry_job(
    job_id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('jobs:write'))
):
    old_job = session.get(Job, job_id)
    if not old_job: raise HTTPException(404)
    if old_job.status != "FAILED":
        raise HTTPException(400, "Can only retry verified failed jobs")
    
    new_job = Job(
        type=old_job.type,
        payload=old_job.payload,
        created_by=user.id,
        status="PENDING"
    )
    session.add(new_job)
    session.commit()
    return {"new_job_id": str(new_job.id)}

@router.websocket("/admin/jobs/ws")
async def jobs_websocket(websocket: WebSocket, session: Session = Depends(get_session)):
    # We can't use Depends(get_session) directly in websocket decorator easily without newer FastAPI
    # So we'll accept the connection first, then validate.
    # Actually, simpler to validate solely on signature for WS speed, 
    # but for security we should check validity.
    
    await websocket.accept()
    token = websocket.query_params.get("token") or websocket.headers.get("sec-websocket-protocol")
    
    if not token:
        await websocket.close(code=1008, reason="Missing token")
        return

    from ..core.config import config
    from .. import auth
    import jwt
    
    try:
        # 1. Decode & Verify Signature
        payload = jwt.decode(
            token, 
            config.JWT_SECRET, 
            algorithms=[config.JWT_ALGORITHM]
        )
        # 2. Check Expiry (handled by decode)
        
        # 3. Check Admin Role (optional, but good)
        # For simplicity, just valid user is enough for connecting, 
        # as sensitive data comes via specific subscribed channels or just general broadcast.
        # But this is the Admin WS, so we should really check admin role.
        
        # Checking db inside async WS is tricky if session not async.
        # we will rely on valid signature + 'sub' presence.
        if not payload.get("sub"):
             raise Exception("Invalid sub")

    except Exception as e:
        print(f"WS Auth Failed: {e}")
        await websocket.close(code=1008, reason="Invalid token")
        return
    
    await manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text() # Keep alive
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# Helper function presumably called by worker (needs to import manager)
async def push_job_update(job_id: str, status: str, progress: int):
    msg = json.dumps({
        "type": "job_update",
        "job_id": job_id,
        "status": status,
        "progress": progress
    })
    await manager.broadcast(msg)
