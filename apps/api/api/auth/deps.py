from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlmodel import Session
from ..core.config import config
from ..core.database import engine
from ..core.models import User
from .service import ALGORITHM, SECRET_KEY

# Defines where the client should send the credentials to get the token
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="v1/auth/login/sms/verify", auto_error=False)

def get_session():
    with Session(engine) as session:
        yield session

async def get_current_user(
    token: str = Depends(oauth2_scheme), 
    session: Session = Depends(get_session)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    # Check if token exists (auto_error=False lets us handle it)
    if not token:
        raise credentials_exception

    if not SECRET_KEY: 
        # API Misconfiguration
        raise HTTPException(status_code=500, detail="Auth configuration missing")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    user = session.get(User, user_id)
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return user

async def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    # Allow 'admin' and 'editor' roles
    if current_user.role not in ["admin", "editor"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="The user doesn't have enough privileges"
        )
    return current_user
