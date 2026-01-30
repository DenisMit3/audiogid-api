
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, text
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

from ..core.database import engine

from ..core.models import AnalyticsDailyStats, ContentEvent
from ..analytics.aggregation import run_daily_aggregation, calculate_cohorts, calculate_retention, calculate_funnel_stats, Poi, Tour, AppEvent, User, UserCohort, RetentionMatrix, Funnel, FunnelStep, FunnelConversion
# ... (rest of imports)

# ... (Previous endpoints)

class FunnelStepCreate(BaseModel):
    order_index: int
    event_type: str
    step_name: Optional[str] = None

class FunnelCreate(BaseModel):
    name: str
    steps: List[FunnelStepCreate]

class FunnelRead(BaseModel):
    id: uuid.UUID
    name: str
    steps: List[Dict[str, Any]]

@router.post("/admin/analytics/funnels", response_model=FunnelRead)
def create_funnel(
    req: FunnelCreate,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('analytics:write'))
):
    funnel = Funnel(name=req.name, owner_id=user.id)
    session.add(funnel)
    session.flush() # get ID
    
    steps = []
    for s in req.steps:
        step = FunnelStep(funnel_id=funnel.id, order_index=s.order_index, event_type=s.event_type, step_name=s.step_name)
        session.add(step)
        steps.append(step)
        
    session.commit()
    session.refresh(funnel)
    
    # Refresh steps
    steps_data = [{"order": s.order_index, "event": s.event_type, "name": s.step_name or s.event_type} for s in steps]
    steps_data.sort(key=lambda x: x['order'])
    
    return FunnelRead(id=funnel.id, name=funnel.name, steps=steps_data)

@router.get("/admin/analytics/funnels", response_model=List[FunnelRead])
def list_funnels(session: Session = Depends(get_session)):
    funnels = session.exec(select(Funnel)).all()
    res = []
    for f in funnels:
        # Load steps
        steps = session.exec(select(FunnelStep).where(FunnelStep.funnel_id == f.id).order_by(FunnelStep.order_index)).all()
        steps_data = [{"order": s.order_index, "event": s.event_type, "name": s.step_name or s.event_type} for s in steps]
        res.append(FunnelRead(id=f.id, name=f.name, steps=steps_data))
    return res

@router.get("/admin/analytics/funnels/{funnel_id}/conversions")
def get_funnel_conversions(
    funnel_id: uuid.UUID,
    days: int = 30,
    session: Session = Depends(get_session)
):
    """
    Returns aggregated conversion data for the funnel.
    Grouped by step.
    Use FunnelConversion table if verified, or compute on fly for MVP?
    Let's compute on fly for MVP to ensure data availability without waiting for job.
    Compute on fly logic:
    1. Get matching users for step 1
    2. detailed funnel steps...
    Actually, funnel analysis on large event stream is heavy.
    Let's use the pre-calculated `FunnelConversion` table if we implement the job.
    BUT, since we haven't implemented the job yet, let's just return stats from `FunnelConversion` assuming they will be filled.
    If empty, return empty stats.
    """
    cutoff = datetime.utcnow() - timedelta(days=days)
    conversions = session.exec(select(FunnelConversion).where(
        FunnelConversion.funnel_id == funnel_id,
        FunnelConversion.date >= cutoff
    )).all()
    
    # Aggregation: Sum users_count per step over the period
    step_stats = {} # { step_order: total_users }
    
    for c in conversions:
        step_stats[c.step_order] = step_stats.get(c.step_order, 0) + c.users_count
        
    # Get Steps definition
    steps = session.exec(select(FunnelStep).where(FunnelStep.funnel_id == funnel_id).order_by(FunnelStep.order_index)).all()
    
    result = []
    base_count = step_stats.get(0, 0) if step_stats else 0
    
    # If no pre-calc data, maybe return empty
    
    for s in steps:
        count = step_stats.get(s.order_index, 0)
        # Drop off from previous
        prev_count = step_stats.get(s.order_index - 1, 0) if s.order_index > 0 else count
        
        # Absolute conversion (from step 0)
        abs_conv = (count / base_count * 100) if base_count > 0 else 0
        
        result.append({
            "step": s.step_name or s.event_type,
            "order": s.order_index,
            "count": count,
            "conversion_rate": abs_conv
        })
        
    return result

# ...

@router.post("/admin/analytics/trigger-cohorts", dependencies=[Depends(require_permission('analytics:write'))])
def trigger_cohorts(session: Session = Depends(get_session)):
    calculate_cohorts(session)
    calculate_retention(session)
    return {"status": "completed"}

@router.post("/admin/analytics/trigger-funnels", dependencies=[Depends(require_permission('analytics:write'))])
def trigger_funnels(session: Session = Depends(get_session)):
    calculate_funnel_stats(session)
    return {"status": "completed"}

@router.get("/admin/analytics/retention")
def get_retention_matrix(session: Session = Depends(get_session)):
    # Return raw list, frontend will pivot
    cutoff = datetime.utcnow() - timedelta(days=60)
    return session.exec(select(RetentionMatrix).where(RetentionMatrix.cohort_date >= cutoff)).all()

@router.get("/admin/analytics/cohorts")
def get_cohorts(session: Session = Depends(get_session)):
    # Return cohort sizes
    # Group by cohort_date, count
    # UserCohort table has raw users.
    cutoff = datetime.utcnow() - timedelta(days=60)
    return session.exec(select(UserCohort.cohort_date, func.count()).where(UserCohort.cohort_date >= cutoff).group_by(UserCohort.cohort_date)).all()


router = APIRouter()

class OverviewKPIs(BaseModel):
    dau: int
    mau: int
    revenue_30d: float
    conversion_rate: float
    sessions_last_7d: int

class TopContentItem(BaseModel):
    id: str
    title: str
    views: int
    type: str

class OverviewResponse(BaseModel):
    kpis: OverviewKPIs
    top_content: List[TopContentItem]
    recent_trend: List[Dict[str, Any]] # Date, DAU, Rev

@router.get("/admin/analytics/overview", response_model=OverviewResponse)
def get_analytics_overview(
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('analytics:read'))
):
    # Simple In-Memory Cache for 5 mins to prevent DB redundant hits
    # In production, use Redis.
    now = datetime.utcnow()
    cache_key = "analytics_overview"
    
    if hasattr(get_analytics_overview, "cache"):
        cached_ts, cached_data = get_analytics_overview.cache
        if (now - cached_ts).total_seconds() < 300: # 5 mins
            return cached_data
            
    # 1. KPIs (Aggregation from AnalyticsDailyStats)
    cutoff_30d = datetime.utcnow() - timedelta(days=30)
    cutoff_7d = datetime.utcnow() - timedelta(days=7)
    
    stats_30d = session.exec(select(AnalyticsDailyStats).where(AnalyticsDailyStats.date >= cutoff_30d)).all()
    
    # Calculate aggregates
    total_rev_30d = sum([s.total_revenue for s in stats_30d])
    avg_dau_7d = 0
    stats_7d = [s for s in stats_30d if s.date >= cutoff_7d]
    if stats_7d:
        avg_dau_7d = sum([s.dau for s in stats_7d]) / len(stats_7d)
    
    # Latest DAU/MAU from most recent entry
    latest = stats_30d[0] if stats_30d else None
    current_dau = latest.dau if latest else 0
    current_mau = latest.mau if latest else 0
    
    # Conversion Rate (Purchase Users / Total Users? Or Sessions?)
    # Crude estimation: Total Purchases last 30d / Total First Opens?
    # Better: just use (Paying Users / MAU)
    # Paying Users isn't pre-calculated in aggregation yet.
    # Stub 2%
    conversion = 0.02

    kpis = OverviewKPIs(
        dau=current_dau,
        mau=current_mau,
        revenue_30d=total_rev_30d,
        conversion_rate=conversion,
        sessions_last_7d=sum([s.sessions_count for s in stats_7d])
    )
    
    # 2. Top Content (Real-time query on ContentEvents)
    # limit to last 7 days for "Popular Now"
    ce_cutoff = datetime.utcnow() - timedelta(days=7)
    # Group by entity_id, count
    # SQLAlchemy/SQLModel Group By
    
    # Raw SQL is easier for Aggregation often
    # "SELECT entity_id, entity_type, COUNT(*) as cnt FROM content_events WHERE ts > :cutoff GROUP BY entity_id, entity_type ORDER BY cnt DESC LIMIT 10"
    
    stmt = text("SELECT entity_id, entity_type, COUNT(*) as cnt FROM content_events WHERE ts > :cutoff GROUP BY entity_id, entity_type ORDER BY cnt DESC LIMIT 5")
    results = session.exec(stmt, params={"cutoff": ce_cutoff}).all()
    
    top_content = []
    for row in results:
        eid = row[0] # uuid or str
        etype = row[1]
        cnt = row[2]
        
        # Fetch Title
        title = "Unknown"
        if etype == "poi":
            p = session.get(Poi, eid)
            if p: title = p.title_ru
        elif etype == "tour":
            t = session.get(Tour, eid)
            if t: title = t.title_ru
            
        top_content.append(TopContentItem(id=str(eid), title=title, views=cnt, type=etype))
    
    # 3. Recent Trend (Charts)
    trend = []
    for s in sorted(stats_30d, key=lambda x: x.date):
        trend.append({
            "date": s.date.strftime("%Y-%m-%d"),
            "dau": s.dau,
            "revenue": s.total_revenue
        })
        
    response = OverviewResponse(kpis=kpis, top_content=top_content, recent_trend=trend)
    get_analytics_overview.cache = (now, response)
    return response

@router.get("/admin/analytics/heatmap")
def get_heatmap_data(
    days: int = 30,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('analytics:read'))
):
    cutoff = datetime.utcnow() - timedelta(days=days)
    # Aggregate POI interactions to generate heatmap
    # count(ContentEvent) group by entity_id where type=poi
    
    stmt = select(Poi.lat, Poi.lon, func.count(ContentEvent.id)).join(
        ContentEvent, 
        (ContentEvent.entity_id == Poi.id) & (ContentEvent.entity_type == 'poi')
    ).where(ContentEvent.ts >= cutoff).group_by(Poi.id, Poi.lat, Poi.lon)
    
    results = session.exec(stmt).all()
    
    # Format: [[lat, lon, intensity], ...]
    points = []
    max_val = 0
    for lat, lon, cnt in results:
        if lat is not None and lon is not None:
             points.append([lat, lon, cnt])
             if cnt > max_val: max_val = cnt
             
    # Normalize intensity 0-1 if client wants, or send raw
    return {"points": points, "max": max_val}
