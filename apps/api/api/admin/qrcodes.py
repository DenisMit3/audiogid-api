
from typing import List, Optional
from datetime import datetime
import uuid
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.models import QRMapping, Poi, Tour, User
from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

class CreateQRReq(BaseModel):
    code: str
    target_type: str
    target_id: uuid.UUID
    label: Optional[str] = None

class BulkGenerateReq(BaseModel):
    target_type: str
    target_ids: List[uuid.UUID]
    prefix: str = "SPB"

@router.get("/admin/qr-mappings", tags=["Admin QR"])
def list_qr_mappings(
    target_type: str | None = None,
    is_active: bool | None = None,
    search: str | None = None,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('qr:read'))
):
    query = select(QRMapping)
    if target_type: query = query.where(QRMapping.target_type == target_type)
    if is_active is not None: query = query.where(QRMapping.is_active == is_active)
    if search: query = query.where(QRMapping.code.ilike(f"%{search}%") | QRMapping.label.ilike(f"%{search}%"))
    return session.exec(query.order_by(QRMapping.created_at.desc())).all()

@router.post("/admin/qr-mappings", tags=["Admin QR"])
def create_qr_mapping(
    req: CreateQRReq,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('qr:write'))
):
    existing = session.exec(select(QRMapping).where(QRMapping.code == req.code)).first()
    if existing: raise HTTPException(400, "Code already exists")
    
    # Check target
    if req.target_type == "poi":
        if not session.get(Poi, req.target_id): raise HTTPException(404, "POI not found")
    elif req.target_type == "tour":
        if not session.get(Tour, req.target_id): raise HTTPException(404, "Tour not found")
    
    mapping = QRMapping(**req.dict())
    session.add(mapping)
    session.commit()
    session.refresh(mapping)
    return mapping

@router.delete("/admin/qr-mappings/{id}", tags=["Admin QR"])
def delete_qr_mapping(
    id: uuid.UUID,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('qr:write'))
):
    mapping = session.get(QRMapping, id)
    if not mapping: raise HTTPException(404, "QR not found")
    session.delete(mapping)
    session.commit()
    return {"status": "deleted"}

@router.post("/admin/qr-mappings/bulk-generate", tags=["Admin QR"])
def bulk_generate_qr_codes(
    req: BulkGenerateReq,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('qr:write'))
):
    created = []
    # Very basic generator. In production, use high-perf counter or random with retry.
    ids = req.target_ids
    
    # Find next suffix start
    # This is O(N) queries, bad for massive bulk, okay for admin < 50 items
    last_qr = session.exec(select(QRMapping).where(QRMapping.code.startswith(req.prefix)).order_by(QRMapping.code.desc())).first()
    start_suffix = 1
    if last_qr:
        try:
            # Try parse existing suffix
            exist_suffix = int(last_qr.code.replace(req.prefix, ""))
            start_suffix = exist_suffix + 1
        except:
            pass

    for i, tid in enumerate(ids):
        suffix = start_suffix + i
        code = f"{req.prefix}{str(suffix).zfill(3)}"
        
        mapping = QRMapping(code=code, target_type=req.target_type, target_id=tid)
        session.add(mapping)
        created.append(code)
    
    session.commit()
    return {"created": created, "count": len(created)}

# --- PUBLIC RESOLVER (Placed here for context, usually in public.py) ---
@router.get("/public/qr/{code}", tags=["Public QR"])
def resolve_qr_code(
    code: str,
    session: Session = Depends(get_session)
):
    mapping = session.exec(select(QRMapping).where(QRMapping.code == code, QRMapping.is_active == True)).first()
    if not mapping: raise HTTPException(404, "QR code not found")
    
    # Increment scan counter
    mapping.scans_count += 1
    mapping.last_scanned_at = datetime.utcnow()
    session.add(mapping)
    session.commit()
    
    return {
        "target_type": mapping.target_type,
        "target_id": str(mapping.target_id),
        "redirect_url": f"/app/{mapping.target_type}/{mapping.target_id}"
    }
