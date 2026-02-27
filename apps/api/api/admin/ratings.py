"""
Admin Ratings API - управление отзывами о турах
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

from ..core.database import engine
from ..core.models import User, TourRating, Tour
from ..auth.deps import get_session, require_permission

router = APIRouter()

# --- Schemas ---

class RatingRead(BaseModel):
    id: uuid.UUID
    tour_id: uuid.UUID
    tour_title: Optional[str] = None
    device_anon_id: str
    user_id: Optional[uuid.UUID] = None
    rating: int
    comment: Optional[str] = None
    created_at: datetime

class RatingStats(BaseModel):
    tour_id: uuid.UUID
    tour_title: str
    avg_rating: float
    total_reviews: int
    rating_distribution: dict  # {1: count, 2: count, ...}

class RatingsListResponse(BaseModel):
    items: List[RatingRead]
    total: int

class RatingsStatsResponse(BaseModel):
    items: List[RatingStats]
    overall_avg: float
    total_reviews: int

# --- Endpoints ---

@router.get("/admin/ratings", response_model=RatingsListResponse)
def list_ratings(
    tour_id: Optional[uuid.UUID] = None,
    rating: Optional[int] = Query(None, ge=1, le=5),
    offset: int = 0,
    limit: int = 50,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('ratings:read'))
):
    """Получить список отзывов с фильтрами"""
    query = select(TourRating).order_by(TourRating.created_at.desc())
    
    if tour_id:
        query = query.where(TourRating.tour_id == tour_id)
    if rating:
        query = query.where(TourRating.rating == rating)
    
    # Count total
    count_query = select(func.count(TourRating.id))
    if tour_id:
        count_query = count_query.where(TourRating.tour_id == tour_id)
    if rating:
        count_query = count_query.where(TourRating.rating == rating)
    total = session.exec(count_query).one()
    
    # Get items
    query = query.offset(offset).limit(limit)
    ratings = session.exec(query).all()
    
    # Enrich with tour titles
    items = []
    for r in ratings:
        tour = session.get(Tour, r.tour_id)
        items.append(RatingRead(
            id=r.id,
            tour_id=r.tour_id,
            tour_title=tour.title_ru if tour else None,
            device_anon_id=r.device_anon_id,
            user_id=r.user_id,
            rating=r.rating,
            comment=r.comment,
            created_at=r.created_at
        ))
    
    return RatingsListResponse(items=items, total=total)

@router.get("/admin/ratings/stats", response_model=RatingsStatsResponse)
def get_ratings_stats(
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('ratings:read'))
):
    """Получить статистику отзывов по турам"""
    # Get all tours with ratings
    stmt = select(
        TourRating.tour_id,
        func.avg(TourRating.rating).label('avg_rating'),
        func.count(TourRating.id).label('total')
    ).group_by(TourRating.tour_id)
    
    results = session.exec(stmt).all()
    
    items = []
    overall_sum = 0
    overall_count = 0
    
    for tour_id, avg_rating, total in results:
        tour = session.get(Tour, tour_id)
        if not tour:
            continue
            
        # Get rating distribution
        dist_stmt = select(
            TourRating.rating,
            func.count(TourRating.id)
        ).where(TourRating.tour_id == tour_id).group_by(TourRating.rating)
        
        dist_results = session.exec(dist_stmt).all()
        distribution = {i: 0 for i in range(1, 6)}
        for r, c in dist_results:
            distribution[r] = c
        
        items.append(RatingStats(
            tour_id=tour_id,
            tour_title=tour.title_ru,
            avg_rating=round(float(avg_rating), 2),
            total_reviews=total,
            rating_distribution=distribution
        ))
        
        overall_sum += float(avg_rating) * total
        overall_count += total
    
    # Sort by avg rating desc
    items.sort(key=lambda x: x.avg_rating, reverse=True)
    
    overall_avg = round(overall_sum / overall_count, 2) if overall_count > 0 else 0
    
    return RatingsStatsResponse(
        items=items,
        overall_avg=overall_avg,
        total_reviews=overall_count
    )

@router.get("/admin/ratings/{rating_id}", response_model=RatingRead)
def get_rating(
    rating_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('ratings:read'))
):
    """Получить отзыв по ID"""
    rating = session.get(TourRating, rating_id)
    if not rating:
        raise HTTPException(404, "Rating not found")
    
    tour = session.get(Tour, rating.tour_id)
    
    return RatingRead(
        id=rating.id,
        tour_id=rating.tour_id,
        tour_title=tour.title_ru if tour else None,
        device_anon_id=rating.device_anon_id,
        user_id=rating.user_id,
        rating=rating.rating,
        comment=rating.comment,
        created_at=rating.created_at
    )

@router.delete("/admin/ratings/{rating_id}")
def delete_rating(
    rating_id: uuid.UUID,
    session: Session = Depends(get_session),
    admin: User = Depends(require_permission('ratings:write'))
):
    """Удалить отзыв"""
    rating = session.get(TourRating, rating_id)
    if not rating:
        raise HTTPException(404, "Rating not found")
    
    session.delete(rating)
    session.commit()
    
    return {"status": "deleted", "id": str(rating_id)}
