
from typing import List, Optional
from uuid import UUID
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, or_, union_all, text
from pydantic import BaseModel

from ..core.models import PoiMedia, TourMedia, User
from ..auth.deps import get_current_admin, get_session, require_permission

router = APIRouter()

class MediaItem(BaseModel):
    id: UUID
    url: str
    media_type: str
    license_type: str
    author: str
    source_page_url: str
    entity_type: str # 'poi' or 'tour'
    entity_id: UUID

class MediaListResponse(BaseModel):
    items: List[MediaItem]
    total: int
    page: int
    per_page: int
    pages: int

@router.get("/admin/media", response_model=MediaListResponse)
def list_all_media(
    type: Optional[str] = None, # image, audio
    entity_type: Optional[str] = None, # poi, tour
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20,
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('media:read'))
):
    # This is tricky with separate tables. 
    # We will fetch from both and combine in memory (easier) or UNION (harder with ORM models).
    # Given modest size, 2 queries + merging sort is okay for v1.
    # For "World Class", we should use UNION ALL in SQL.
    
    # Let's try to construct a UNION query using direct SQL or strict SQLModel if possible.
    # Since columns are identical except FK name, we can select compatible columns.
    
    # SQL Approach for performance:
    query_str = """
    SELECT id, url, media_type, license_type, author, source_page_url, 'poi' as entity_type, poi_id as entity_id
    FROM poi_media
    WHERE (:type IS NULL OR media_type = :type)
    UNION ALL
    SELECT id, url, media_type, license_type, author, source_page_url, 'tour' as entity_type, tour_id as entity_id
    FROM tour_media
    WHERE (:type IS NULL OR media_type = :type)
    """
    
    # We need to handle pagination and filtering on the union result.
    # Wrapping in CTE or subquery
    
    wrapper_sql = f"""
    WITH all_media AS (
        {query_str}
    )
    SELECT * FROM all_media
    """
    
    filters = []
    params = {"type": type}
    
    if entity_type:
        filters.append("entity_type = :entity_type")
        params["entity_type"] = entity_type
        
    if search:
        filters.append("(author ILIKE :search OR url ILIKE :search)")
        params["search"] = f"%{search}%"
        
    if filters:
        wrapper_sql += " WHERE " + " AND ".join(filters)
        
    # Validation/Total count
    count_sql = f"SELECT count(*) FROM ({wrapper_sql}) as counted"
    total = session.exec(text(count_sql), params=params).one()
    
    # Pagination
    final_sql = f"{wrapper_sql} LIMIT :limit OFFSET :offset"
    params["limit"] = per_page
    params["offset"] = (page - 1) * per_page
    
    rows = session.exec(text(final_sql), params=params).all()
    
    items = []
    for row in rows:
        # row is tuple/mapping depending on driver. SQLModel/SQLAlchemy usually returns tuple for text queries
        # (id, url, media_type, license_type, author, source_page_url, entity_type, entity_id)
        items.append(MediaItem(
            id=row[0],
            url=row[1],
            media_type=row[2],
            license_type=row[3],
            author=row[4],
            source_page_url=row[5],
            entity_type=row[6],
            entity_id=row[7]
        ))
        
    return {
        "items": items,
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }

@router.delete("/admin/media/{media_id}")
def delete_media(
    media_id: UUID,
    entity_type: str = Query(..., regex="^(poi|tour)$"), # Required to know table
    session: Session = Depends(get_session),
    user: User = Depends(require_permission('media:delete'))
):
    if entity_type == 'poi':
        media = session.get(PoiMedia, media_id)
        if not media: raise HTTPException(404, "Media not found")
        session.delete(media)
    elif entity_type == 'tour':
        media = session.get(TourMedia, media_id)
        if not media: raise HTTPException(404, "Media not found")
        session.delete(media)
        
    session.commit()
    return {"status": "deleted"}
