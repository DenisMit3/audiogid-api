import uuid
import logging
import hashlib
from datetime import datetime, timedelta
from typing import Optional, Tuple
from sqlmodel import Session, select
from jose import jwt

from ..core.models import User, UserIdentity, OtpCode
from ..core.config import config
from .sms import send_sms_otp, generate_otp
from .telegram import verify_telegram_data

logger = logging.getLogger(__name__)

ALGORITHM = config.JWT_ALGORITHM or "HS256"
SECRET_KEY = config.JWT_SECRET

if not SECRET_KEY:
    logger.warning("JWT_SECRET not set! Auth will likely fail to sign tokens.")

def create_access_token(user_id: uuid.UUID, role: str) -> str:
    if not SECRET_KEY: raise RuntimeError("JWT_SECRET missing configuration")
    # Long expiration for mobile app usability (30 days)
    # Security tradeoff: client must secure token; revocation via 'is_active' check in middleware
    expire = datetime.utcnow() + timedelta(days=30) 
    to_encode = {"sub": str(user_id), "role": role, "exp": expire, "type": "access"}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def initiate_sms_login(session: Session, phone: str) -> Tuple[bool, str]:
    """Returns (success, message/error)"""
    # Clean phone
    # Basic normalization
    clean_phone = phone.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    if clean_phone.startswith("8"): clean_phone = "+7" + clean_phone[1:]
    elif clean_phone.startswith("7") and not clean_phone.startswith("+"): clean_phone = "+" + clean_phone
    
    if len(clean_phone) < 6: return False, "Invalid phone"

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

def verify_sms_login(session: Session, phone: str, code: str) -> Tuple[Optional[str], str]:
    """Returns (token, error)"""
    clean_phone = phone.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    if clean_phone.startswith("8"): clean_phone = "+7" + clean_phone[1:]
    elif clean_phone.startswith("7") and not clean_phone.startswith("+"): clean_phone = "+" + clean_phone

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

def verify_telegram_login(session: Session, data: dict) -> Tuple[Optional[str], str]:
    if not verify_telegram_data(data):
        return None, "Invalid telegram signature"
        
    tg_id = data.get("id")
    username = data.get("username")
    
    force_admin = False
    if username == "RezidentMD":
        force_admin = True

    if not tg_id: return None, "Missing Telegram ID"
    
    return get_or_create_user_token(session, "telegram", str(tg_id), force_admin=force_admin)

def get_or_create_user_token(session: Session, provider: str, provider_id: str, force_admin: bool = False) -> Tuple[str, str]:
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
    
    token = create_access_token(user.id, user.role)
    return token, "OK"
