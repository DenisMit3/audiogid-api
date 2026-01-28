
from sqlmodel import Session, select, func, text
from datetime import datetime, timedelta
from ..core.models import AppEvent, ContentEvent, PurchaseEvent, AnalyticsDailyStats, UserCohort, RetentionMatrix
import logging

logger = logging.getLogger(__name__)

def run_daily_aggregation(session: Session, target_date: datetime = None):
    """
    Aggregates events into daily stats.
    Target date is usually yesterday (full day).
    If None, assumes 'yesterday'.
    """
    if not target_date:
        target_date = datetime.utcnow().date() - timedelta(days=1)
    
    # Range
    start_dt = datetime.combine(target_date, datetime.min.time())
    end_dt = datetime.combine(target_date, datetime.max.time())
    
    logger.info(f"Running aggregation for {target_date}")
    
    # 1. DAU (Unique Anon IDs in AppEvents + ContentEvents)
    # Simplified: just count count distinct anon_id in AppEvent for now
    dau_query = select(func.count(func.distinct(AppEvent.anon_id))).where(AppEvent.ts >= start_dt, AppEvent.ts <= end_dt)
    dau = session.exec(dau_query).one() or 0
    
    # 2. Revenue
    rev_query = select(func.sum(PurchaseEvent.amount)).where(PurchaseEvent.ts >= start_dt, PurchaseEvent.ts <= end_dt)
    revenue = session.exec(rev_query).one() or 0.0
    
    # 3. New Users (First seen today)
    # This requires looking up if anon_id appeared before. Expensive without UserCohort table pre-filled.
    # We populate UserCohort on the fly for new users?
    # For MVP, omit or estimate.
    new_users = 0
    
    # 4. Sessions (App Open events)
    sessions = session.exec(select(func.count()).where(AppEvent.event_type == "app_open", AppEvent.ts >= start_dt, AppEvent.ts <= end_dt)).one() or 0
    
    # Save/Update
    stats = session.get(AnalyticsDailyStats, target_date)
    if not stats:
        stats = AnalyticsDailyStats(date=target_date)
    
    stats.dau = dau
    stats.total_revenue = revenue
    stats.sessions_count = sessions
    session.add(stats)
    session.commit()
    
    logger.info(f"Aggregation complete: DAU={dau}, Rev={revenue}")
    return stats


def get_user_uuid(anon_id: str) -> str:
    # Deterministic UUID from anon_id
    import uuid
    return str(uuid.uuid5(uuid.NAMESPACE_OID, anon_id))

def calculate_cohorts(session: Session):
    """
    Populates UserCohort table from AppEvents.
    """
    logger.info("Computing Cohorts...")
    
    # 1. Find all distinct anon_ids and their first seen date
    # This might be heavy on large data, but fine for MVP (<1M rows)
    # Optimized: Only process anon_ids NOT currently in UserCohorts?
    # For MVP: Load all known anon_ids from UserCohorts to memory set
    
    existing_ids = {str(uid) for uid in session.exec(select(UserCohort.user_id)).all()}
    
    # Stream events distinct anon_id
    # SQLAlchemy distinct
    # "SELECT anon_id, MIN(ts) FROM app_events GROUP BY anon_id"
    # Filter where anon_id not null
    
    result = session.exec(text("SELECT anon_id, MIN(ts) as first_seen FROM app_events WHERE anon_id IS NOT NULL GROUP BY anon_id")).all()
    
    new_cohorts = []
    import uuid
    for row in result:
        aid = row[0]
        first_seen = row[1]
        
        # Convert to UUID
        try:
             uid = uuid.uuid5(uuid.NAMESPACE_OID, aid)
             if str(uid) not in existing_ids:
                 new_cohorts.append(UserCohort(user_id=uid, cohort_date=first_seen))
                 existing_ids.add(str(uid)) # Prevent dups in batch
        except:
             continue
             
    if new_cohorts:
        session.add_all(new_cohorts)
        session.commit()
        logger.info(f"Added {len(new_cohorts)} new users to cohorts")

def calculate_retention(session: Session):
    """
    Calculates RetentionMatrix.
    Re-computes for last 60 days.
    """
    logger.info("Computing Retention...")
    
    # 1. Get Cohorts (Groups of users by date)
    # Group users by date(cohort_date)
    # Map: { date_str: [user_uuids] }
    
    # Optimization: Do in SQL?
    # Hard to map UUID back to anon_id for joining AppEvents if we lost the mapping.
    # Logic: AppEvent.anon_id -> UUID5 -> match UserCohort.user_id
    
    # We can do this:
    # Select all AppEvents (anon_id, date)
    # Convert anon_id to UUID
    # Join with UserCohort (user_id, cohort_date)
    # Group by (cohort_date, event_date - cohort_date)
    
    # This implies loading all events? Or doing complex SQL causing function scan.
    # Let's do python logic for MVP (assuming daily volume < 10k events).
    
    # A. Get all users and their cohort dates
    users = session.exec(select(UserCohort)).all()
    user_cohort_map = {str(u.user_id): u.cohort_date.date() for u in users}
    
    # B. Get all activity (anon_id, date)
    # Distinct per day per user
    events = session.exec(text("SELECT DISTINCT anon_id, date(ts) FROM app_events WHERE anon_id IS NOT NULL")).all()
    
    cohort_stats = {} # { cohort_date: { day_n: count } }
    cohort_sizes = {} # { cohort_date: size }
    
    # Init sizes
    for u in users:
        d = u.cohort_date.date()
        cohort_sizes[d] = cohort_sizes.get(d, 0) + 1
        
    import uuid
    for row in events:
        aid = row[0]
        evt_date = datetime.strptime(row[1], "%Y-%m-%d").date() if isinstance(row[1], str) else row[1]
        
        uid = str(uuid.uuid5(uuid.NAMESPACE_OID, aid))
        
        if uid in user_cohort_map:
            c_date = user_cohort_map[uid]
            day_n = (evt_date - c_date).days
            
            if day_n >= 0:
                if c_date not in cohort_stats: cohort_stats[c_date] = {}
                # Use set to count distinct users for that day?
                # Actually, `events` query is DISTINCT anon_id, date.
                # So just incrementing is fine IF one user maps to one anon_id.
                # Yes.
                cohort_stats[c_date][day_n] = cohort_stats[c_date].get(day_n, 0) + 1

    # C. Write to DB
    # Clear old matrix? Or Update.
    # Let's Clear for simplicity or Merge.
    session.exec(text("DELETE FROM retention_matrix"))
    
    matrix_rows = []
    for c_date, daily_counts in cohort_stats.items():
        size = cohort_sizes.get(c_date, 1)
        for day_n, count in daily_counts.items():
             # Only store key days to save space? Or all.
             if day_n in [0, 1, 3, 7, 14, 30]:
                pct = (count / size) * 100.0
                matrix_rows.append(RetentionMatrix(
                    cohort_date=c_date,
                    day_n=day_n,
                    retained_count=count,
                    percentage=pct
                ))
                
    if matrix_rows:
        session.add_all(matrix_rows)
        session.commit()
        logger.info(f"Retention matrix updated: {len(matrix_rows)} rows")


def calculate_funnel_stats(session: Session, target_date: datetime = None):
    """
    Calculates daily stats for all defined funnels.
    Loose funnel logic: Count unique users per step event on that day.
    """
    from ..core.models import Funnel, FunnelStep, FunnelConversion
    
    if not target_date:
        target_date = datetime.utcnow().date() - timedelta(days=1)
        
    start_dt = datetime.combine(target_date, datetime.min.time())
    end_dt = datetime.combine(target_date, datetime.max.time())
    
    logger.info(f"Computing Funnels for {target_date}...")
    
    funnels = session.exec(select(Funnel)).all()
    
    conversions = []
    
    for f in funnels:
        # Load steps
        steps = session.exec(select(FunnelStep).where(FunnelStep.funnel_id == f.id)).all()
        
        for step in steps:
            # Check AppEvents
            c_app = session.exec(select(func.count(func.distinct(AppEvent.anon_id))).where(
                AppEvent.event_type == step.event_type,
                AppEvent.ts >= start_dt,
                AppEvent.ts <= end_dt
            )).one() or 0
            
            # Check ContentEvents
            c_content = session.exec(select(func.count(func.distinct(ContentEvent.anon_id))).where(
                ContentEvent.event_type == step.event_type,
                ContentEvent.ts >= start_dt,
                ContentEvent.ts <= end_dt
            )).one() or 0
            
            # Total unique (approximation: sum is upper bound if disjoint, but they might overlap?)
            # Usually event types don't overlap between tables. "app_open" is ONLY in AppEvents. "tour_started" ONLY in ContentEvents.
            # So Sum is safe.
            total = c_app + c_content
            
            conversions.append(FunnelConversion(
                date=target_date,
                funnel_id=f.id,
                step_order=step.order_index,
                users_count=total
            ))
            
    if conversions:
        session.add_all(conversions)
        session.commit()
        logger.info(f"Funnel stats updated: {len(conversions)} entries")


