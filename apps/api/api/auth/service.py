import uuid
import logging
import hashlib
from datetime import datetime, timedelta
from typing import Optional, Tuple
from sqlmodel import Session, select
from jose import jwt

from ..core.models import User, UserIdentity, OtpCode, BlacklistedToken
from ..core.config import config
from .sms import send_sms_otp, generate_otp
from .telegram import verify_telegram_data

logger = logging.getLogger(__name__)

ALGORITHM = config.JWT_ALGORITHM or "HS256"
SECRET_KEY = config.JWT_SECRET

REVIEWER_PHONES = ["+79000000000", "+79999999999"]

if not SECRET_KEY:
    logger.warning("JWT_SECRET not set! Auth will likely fail to sign tokens.")

from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(user_id: uuid.UUID, role: str) -> str:
    if not SECRET_KEY: raise RuntimeError("JWT_SECRET missing configuration")
    # Shorten access_token TTL to 15-30min (per prompt)
    expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode = {"sub": str(user_id), "role": role, "exp": expire, "type": "access"}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(user_id: uuid.UUID) -> str:
    if not SECRET_KEY: raise RuntimeError("JWT_SECRET missing configuration")
    expire = datetime.utcnow() + timedelta(days=7) # Refresh token lives 7 days (per prompt)
    to_encode = {"sub": str(user_id), "exp": expire, "type": "refresh"}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def verify_token(token: str, expected_type: str = "access") -> Optional[dict]:
    if not SECRET_KEY: return None
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        if payload.get("type") != expected_type:
            return None
        return payload
    except Exception:
        return None

def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()

def blacklist_token(session: Session, token: str, expires_at: datetime, user_id: Optional[uuid.UUID] = None) -> None:
    token_hash = hash_token(token)
    # Check if already blacklisted
    if session.get(BlacklistedToken, token_hash):
        return
    
    blacklisted = BlacklistedToken(
        token_hash=token_hash,
        expires_at=expires_at,
        user_id=user_id
    )
    session.add(blacklisted)
    session.commit()

def is_token_blacklisted(session: Session, token: str) -> bool:
    token_hash = hash_token(token)
    # Check for expired blacklisted tokens cleanup here? No, separate job.
    # Just check existence
    found = session.get(BlacklistedToken, token_hash)
    if not found: return False
    
    # If it's expired in the DB, it's still blacklisted, but theoretically doesn't matter.
    return True

async def initiate_sms_login(session: Session, phone: str) -> Tuple[bool, str]:
    """Returns (success, message/error)"""
    # Clean phone
    # Basic normalization
    clean_phone = phone.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    if clean_phone.startswith("8"): clean_phone = "+7" + clean_phone[1:]
    elif clean_phone.startswith("7") and not clean_phone.startswith("+"): clean_phone = "+" + clean_phone
    
    if len(clean_phone) < 6: return False, "Invalid phone"

    if clean_phone in REVIEWER_PHONES:
        return True, "SMS sent (Reviewer)"

    # Throttle Check
    recent = session.exec(select(OtpCode).where(
        OtpCode.phone == clean_phone,
        OtpCode.expires_at > datetime.utcnow(),
        OtpCode.used == False
    ).order_by(OtpCode.created_at.desc())).first()
    
    if recent and (datetime.utcnow() - recent.created_at).seconds < 60:
        return False, "Too many requests. Wait 60s."

    code = generate_otp()
    ttl = config.OTP_TTL_SECONDS
    otp = OtpCode(
        phone=clean_phone, 
        code=code, 
        expires_at=datetime.utcnow() + timedelta(seconds=ttl)
    )
    session.add(otp)
    session.commit()
    
    # Send Async
    sent = await send_sms_otp(clean_phone, code)
    if sent:
        return True, "SMS sent"
    else:
        # In DEV without credentials, send logic returns False.
        # But we created the code in DB.
        # If config.SMSRU is missing, we might want to return True but log warning?
        # POLICY: No fake success.
        # So return False.
        return False, "Failed to send SMS (Provider Error)"




def verify_sms_login(session: Session, phone: str, code: str) -> Tuple[Optional[dict], str]:
    """Returns (tokens, error)"""
    clean_phone = phone.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    if clean_phone.startswith("8"): clean_phone = "+7" + clean_phone[1:]
    elif clean_phone.startswith("7") and not clean_phone.startswith("+"): clean_phone = "+" + clean_phone

    # Reviewer Bypass
    if clean_phone in REVIEWER_PHONES and code == "123456":
         return get_or_create_user_token(session, "phone", clean_phone)

    otp = session.exec(select(OtpCode).where(
        OtpCode.phone == clean_phone,
        OtpCode.expires_at > datetime.utcnow(),
        OtpCode.used == False,
        OtpCode.code == code
    )).first()
    
    if not otp:
        return None, "Invalid or expired code"
        
    otp.used = True
    session.add(otp)
    session.commit()
    
    return get_or_create_user_token(session, "phone", clean_phone)

def verify_telegram_login(session: Session, data: dict) -> Tuple[Optional[dict], str]:
    if not verify_telegram_data(data):
        return None, "Invalid telegram signature"
        
    tg_id = data.get("id")
    username = data.get("username")
    
    # Removed force_admin logic for RezidentMD to restrict admin access
    force_admin = False

    if not tg_id: return None, "Missing Telegram ID"
    
    return get_or_create_user_token(session, "telegram", str(tg_id), force_admin=force_admin)

def get_or_create_user_token(session: Session, provider: str, provider_id: str, force_admin: bool = False) -> Tuple[Optional[dict], str]:
    # Lookup Identity
    identity = session.exec(select(UserIdentity).where(
        UserIdentity.provider == provider,
        UserIdentity.provider_id == provider_id
    )).first()
    
    user = None
    if identity:
        identity.last_login = datetime.utcnow()
        session.add(identity)
        user = session.get(User, identity.user_id)
        if not user.is_active:
            return None, "User account disabled"
            
        # Promote to admin if matches hardcoded logic
        if force_admin and user.role != "admin":
            user.role = "admin"
            session.add(user)
            session.commit()
    else:
        # Create User
        role = "admin" if force_admin else "user"
        user = User(role=role)
        session.add(user)
        session.commit()
        session.refresh(user)
        
        identity = UserIdentity(
            user_id=user.id, 
            provider=provider, 
            provider_id=provider_id, 
            last_login=datetime.utcnow()
        )
        session.add(identity)
        session.commit()
    
    access_token = create_access_token(user.id, user.role)
    refresh_token = create_refresh_token(user.id)
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}, "OK"
