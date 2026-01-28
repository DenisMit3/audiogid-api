from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlmodel import Session
from ..core.database import engine
from ..core.models import User
import uuid

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token", auto_error=False)

def get_session() -> Generator:
    with Session(engine) as session:
        yield session

# --- SECURITY DISABLED BY USER REQUEST ---
# All requests are automatically treated as authenticated Admin.

def get_current_user() -> User:
    """
    Bypass authentication completely.
    Returns a dummy Admin user for every request.
    """
    return User(
        id=uuid.UUID("00000000-0000-0000-0000-000000000000"),
        role="admin",
        is_active=True
    )

def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    """
    Allow access to everyone as Admin.
    """
    return current_user
