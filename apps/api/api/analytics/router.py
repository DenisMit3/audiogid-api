
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlmodel import Session, select
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime, timedelta
import uuid

from ..core.models import AppEvent, ContentEvent, PurchaseEvent
from ..auth.deps import get_session, get_current_user_optional, require_permission, get_current_admin
from ..core.models import User

router = APIRouter()

class EventIngest(BaseModel):
    event_id: uuid.UUID
    event_type: str
    ts: Optional[datetime] = None
    payload: Optional[Dict[str, Any]] = None
    
class BatchIngestReq(BaseModel):
    anon_id: Optional[str] = None
    events: List[EventIngest]

@router.post("/analytics/events", status_code=202)
def ingest_events(
    req: BatchIngestReq,
    background_tasks: BackgroundTasks,
    session: Session = Depends(get_session),
    # User might be optional if tracking anonymous via anon_id
    user: Optional[User] = Depends(get_current_user_optional) 
):
    """
    Ingest a batch of events.
    Uses BackgroundTasks or inserts directly (direct is fine for MVP volume).
    """
    user_id = user.id if user else None
    
    # Process events
    app_events = []
    
    # We could separate Content/Purchase here if the client sends them with specific types
    # Or strict 'type' checking.
    # For now, put everything in AppEvent unless it looks special.
    
    for e in req.events:
        # Check idempotency? (Skip for high-throughput MVP, assume client reliable or dups accepted)
        # Actually, let's just insert.
        
        # Determine if ContentEvent?
        # e.g. type="content:poi_viewed"
        
        # Simple Logic: Everything to AppEvent for generic tracking
        # If we need fast lookups for Content, we double write or filter later.
        
        evt = AppEvent(
            id=e.event_id,
            ts=e.ts or datetime.utcnow(),
            event_type=e.event_type,
            user_id=user_id,
            anon_id=req.anon_id,
            payload_json=str(e.payload) if e.payload else None
        )
        app_events.append(evt)
        
    session.add_all(app_events)
    session.commit()
    
    return {"status": "queued", "count": len(app_events)}


from .aggregation import run_daily_aggregation
from ..core.models import AnalyticsDailyStats

# ...

@router.post("/analytics/trigger-aggregation", dependencies=[Depends(require_permission('analytics:write'))])
def trigger_aggregation(
    date: Optional[datetime] = None,
    session: Session = Depends(get_session)
):
    """Manually trigger aggregation for a specific date (default: yesterday)."""
    stats = run_daily_aggregation(session, date.date() if date else None)
    return {"status": "completed", "stats": stats}

@router.get("/analytics/stats", response_model=List[AnalyticsDailyStats])
def get_analytics_stats(
    days: int = 30,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('analytics:read'))
):
    cutoff = datetime.utcnow() - timedelta(days=days)
    return session.exec(select(AnalyticsDailyStats).where(AnalyticsDailyStats.date >= cutoff).order_by(AnalyticsDailyStats.date.desc())).all()


