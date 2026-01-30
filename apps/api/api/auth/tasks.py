from datetime import datetime
from sqlmodel import Session, select
from ..core.models import BlacklistedToken

def cleanup_blacklisted_tokens(session: Session) -> int:
    """
    Deletes expired blacklisted tokens.
    Returns the number of deleted tokens.
    """
    statement = select(BlacklistedToken).where(BlacklistedToken.expires_at < datetime.utcnow())
    expired_tokens = session.exec(statement).all()
    
    count = 0
    for token in expired_tokens:
        session.delete(token)
        count += 1
        
    session.commit()
    return count
