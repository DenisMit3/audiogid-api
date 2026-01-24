from fastapi import APIRouter, Depends, HTTPException, Response
from sqlmodel import Session, text
from ..core.database import engine

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/ops/health")
def health_check():
    """
    Liveness probe. Always 200 if app is running.
    """
    return {"status": "ok", "timestamp": "now"}

@router.get("/ops/ready")
def readiness_check(session: Session = Depends(get_session)):
    """
    Readiness probe. Checks DB connection.
    Returns 500 if DB unavailable.
    """
    try:
        # Simple query
        session.exec(text("SELECT 1"))
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database Unavailable: {str(e)}")
