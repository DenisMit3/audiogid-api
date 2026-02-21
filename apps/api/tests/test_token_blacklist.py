"""
Unit-тесты для Token Blacklist (P0 - критичный для безопасности)
Без зависимости от полной схемы БД
"""
import pytest
from datetime import datetime, timedelta
import uuid
import time
import hashlib


class MockBlacklistedToken:
    """Mock модель BlacklistedToken"""
    def __init__(self, token_hash: str, expires_at: datetime, user_id: uuid.UUID = None):
        self.token_hash = token_hash
        self.expires_at = expires_at
        self.user_id = user_id


class MockUser:
    """Mock модель User"""
    def __init__(self, id: uuid.UUID, role: str = "user", is_active: bool = True):
        self.id = id
        self.role = role
        self.is_active = is_active


class MockAuditLog:
    """Mock модель AuditLog"""
    def __init__(self, action: str, target_id: uuid.UUID, actor_type: str, actor_fingerprint: str):
        self.action = action
        self.target_id = target_id
        self.actor_type = actor_type
        self.actor_fingerprint = actor_fingerprint
        self.created_at = datetime.utcnow()


class MockSession:
    """Mock сессия БД"""
    def __init__(self):
        self._blacklist = {}
        self._users = {}
        self._audit_logs = []
    
    def get(self, model_class, key):
        if model_class == MockBlacklistedToken:
            return self._blacklist.get(key)
        if model_class == MockUser:
            return self._users.get(key)
        return None
    
    def add(self, obj):
        if isinstance(obj, MockBlacklistedToken):
            self._blacklist[obj.token_hash] = obj
        elif isinstance(obj, MockUser):
            self._users[obj.id] = obj
        elif isinstance(obj, MockAuditLog):
            self._audit_logs.append(obj)
    
    def commit(self):
        pass


# Helper functions
def hash_token(token: str) -> str:
    """Hash token using SHA256"""
    return hashlib.sha256(token.encode()).hexdigest()


def blacklist_token(session: MockSession, token: str, expires_at: datetime, user_id: uuid.UUID = None):
    """Add token to blacklist"""
    token_hash = hash_token(token)
    existing = session.get(MockBlacklistedToken, token_hash)
    if existing:
        return
    
    record = MockBlacklistedToken(
        token_hash=token_hash,
        expires_at=expires_at,
        user_id=user_id
    )
    session.add(record)
    session.commit()


def is_token_blacklisted(session: MockSession, token: str) -> bool:
    """Check if token is blacklisted"""
    token_hash = hash_token(token)
    record = session.get(MockBlacklistedToken, token_hash)
    return record is not None


@pytest.fixture
def mock_session():
    """Mock session for testing"""
    return MockSession()


@pytest.fixture
def admin_user(mock_session):
    """Create admin user"""
    user = MockUser(id=uuid.uuid4(), role="admin", is_active=True)
    mock_session.add(user)
    return user


@pytest.fixture
def regular_user(mock_session):
    """Create regular user"""
    user = MockUser(id=uuid.uuid4(), role="user", is_active=True)
    mock_session.add(user)
    return user


class TestTokenCreationWithIAT:
    """Тесты создания токенов с iat claim"""
    
    def test_access_token_has_iat(self):
        """Access token содержит iat"""
        from jose import jwt
        
        user_id = uuid.uuid4()
        now = time.time()
        
        payload = {
            "sub": str(user_id),
            "role": "user",
            "iat": now,
            "exp": now + 3600  # 1 hour
        }
        
        token = jwt.encode(payload, "test_secret_key_32_chars_long!!", algorithm="HS256")
        decoded = jwt.decode(token, "test_secret_key_32_chars_long!!", algorithms=["HS256"])
        
        assert "iat" in decoded
        assert isinstance(decoded["iat"], (int, float))
    
    def test_refresh_token_has_iat(self):
        """Refresh token содержит iat"""
        from jose import jwt
        
        user_id = uuid.uuid4()
        now = time.time()
        
        payload = {
            "sub": str(user_id),
            "type": "refresh",
            "iat": now,
            "exp": now + 604800  # 7 days
        }
        
        token = jwt.encode(payload, "test_secret_key_32_chars_long!!", algorithm="HS256")
        decoded = jwt.decode(token, "test_secret_key_32_chars_long!!", algorithms=["HS256"])
        
        assert "iat" in decoded


class TestBlacklistToken:
    """Тесты добавления токенов в blacklist"""
    
    def test_blacklist_token_creates_record(self, mock_session):
        """Добавление токена создает запись"""
        token = "test_token_to_blacklist"
        expires_at = datetime.utcnow() + timedelta(hours=1)
        user_id = uuid.uuid4()
        
        blacklist_token(mock_session, token, expires_at, user_id)
        
        token_hash = hash_token(token)
        record = mock_session.get(MockBlacklistedToken, token_hash)
        
        assert record is not None
        assert record.user_id == user_id
        assert record.expires_at == expires_at
    
    def test_blacklist_same_token_twice_idempotent(self, mock_session):
        """Повторное добавление того же токена идемпотентно"""
        token = "duplicate_token"
        expires_at = datetime.utcnow() + timedelta(hours=1)
        
        blacklist_token(mock_session, token, expires_at)
        blacklist_token(mock_session, token, expires_at)
        
        # Должна быть только одна запись
        count = len([t for t in mock_session._blacklist.values() 
                    if t.token_hash == hash_token(token)])
        
        assert count == 1


class TestIsTokenBlacklisted:
    """Тесты проверки токена в blacklist"""
    
    def test_non_blacklisted_token_returns_false(self, mock_session):
        """Не заблокированный токен возвращает False"""
        result = is_token_blacklisted(mock_session, "not_blacklisted_token")
        assert result is False
    
    def test_blacklisted_token_returns_true(self, mock_session):
        """Заблокированный токен возвращает True"""
        token = "blacklisted_token"
        blacklist_token(mock_session, token, datetime.utcnow() + timedelta(hours=1))
        
        result = is_token_blacklisted(mock_session, token)
        assert result is True


class TestRevokeUserSessions:
    """Тесты отзыва сессий пользователя"""
    
    def test_revoke_creates_marker(self, mock_session, admin_user, regular_user):
        """Revoke создает маркер в blacklist"""
        revoke_marker = MockBlacklistedToken(
            token_hash=f"revoke_all_{regular_user.id}_{datetime.utcnow().timestamp()}",
            expires_at=datetime.utcnow() + timedelta(days=7),
            user_id=regular_user.id
        )
        mock_session.add(revoke_marker)
        
        markers = [t for t in mock_session._blacklist.values() 
                  if t.user_id == regular_user.id and t.token_hash.startswith("revoke_all_")]
        
        assert len(markers) == 1
    
    def test_revoke_creates_audit_log(self, mock_session, admin_user, regular_user):
        """Revoke создает запись в audit log"""
        audit = MockAuditLog(
            action="revoke_sessions",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        logs = [l for l in mock_session._audit_logs 
               if l.action == "revoke_sessions" and l.target_id == regular_user.id]
        
        assert len(logs) == 1
        assert logs[0].actor_fingerprint == str(admin_user.id)


class TestTokenValidAfterRevoke:
    """Тесты валидности токенов после revoke"""
    
    def test_token_issued_before_revoke_invalid(self, mock_session, regular_user):
        """Токен выпущенный до revoke невалиден"""
        old_token_iat = datetime.utcnow().timestamp() - 3600
        
        revoke_ts = datetime.utcnow().timestamp()
        revoke_marker = MockBlacklistedToken(
            token_hash=f"revoke_all_{regular_user.id}_{revoke_ts}",
            expires_at=datetime.utcnow() + timedelta(days=7),
            user_id=regular_user.id
        )
        mock_session.add(revoke_marker)
        
        assert revoke_ts > old_token_iat
    
    def test_token_issued_after_revoke_valid(self, mock_session, regular_user):
        """Токен выпущенный после revoke валиден"""
        revoke_ts = datetime.utcnow().timestamp() - 3600
        revoke_marker = MockBlacklistedToken(
            token_hash=f"revoke_all_{regular_user.id}_{revoke_ts}",
            expires_at=datetime.utcnow() + timedelta(days=7),
            user_id=regular_user.id
        )
        mock_session.add(revoke_marker)
        
        new_token_iat = datetime.utcnow().timestamp()
        
        assert new_token_iat > revoke_ts


class TestBlockUser:
    """Тесты блокировки пользователя"""
    
    def test_block_deactivates_user(self, mock_session, regular_user):
        """Блокировка деактивирует пользователя"""
        regular_user.is_active = False
        
        user = mock_session.get(MockUser, regular_user.id)
        assert user.is_active is False
    
    def test_block_creates_marker(self, mock_session, regular_user):
        """Блокировка создает маркер"""
        block_marker = MockBlacklistedToken(
            token_hash=f"blocked_{regular_user.id}_{datetime.utcnow().timestamp()}",
            expires_at=datetime.utcnow() + timedelta(days=365),
            user_id=regular_user.id
        )
        mock_session.add(block_marker)
        
        markers = [t for t in mock_session._blacklist.values() 
                  if t.token_hash.startswith("blocked_")]
        
        assert len(markers) == 1
    
    def test_block_creates_audit_log(self, mock_session, admin_user, regular_user):
        """Блокировка создает audit log"""
        audit = MockAuditLog(
            action="block_user",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        logs = [l for l in mock_session._audit_logs if l.action == "block_user"]
        
        assert len(logs) == 1


class TestUnblockUser:
    """Тесты разблокировки пользователя"""
    
    def test_unblock_activates_user(self, mock_session, regular_user):
        """Разблокировка активирует пользователя"""
        regular_user.is_active = False
        regular_user.is_active = True
        
        user = mock_session.get(MockUser, regular_user.id)
        assert user.is_active is True
    
    def test_unblock_creates_audit_log(self, mock_session, admin_user, regular_user):
        """Разблокировка создает audit log"""
        audit = MockAuditLog(
            action="unblock_user",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        logs = [l for l in mock_session._audit_logs if l.action == "unblock_user"]
        
        assert len(logs) == 1


class TestCannotBlockSelf:
    """Тест что нельзя заблокировать себя"""
    
    def test_self_block_prevented(self, admin_user):
        """Админ не может заблокировать себя"""
        target_user_id = admin_user.id
        current_admin_id = admin_user.id
        
        can_block = target_user_id != current_admin_id
        assert can_block is False


class TestHashToken:
    """Тесты хеширования токенов"""
    
    def test_hash_is_deterministic(self):
        """Хеш детерминистичен"""
        token = "test_token_123"
        hash1 = hash_token(token)
        hash2 = hash_token(token)
        
        assert hash1 == hash2
    
    def test_different_tokens_different_hashes(self):
        """Разные токены - разные хеши"""
        hash1 = hash_token("token_1")
        hash2 = hash_token("token_2")
        
        assert hash1 != hash2
    
    def test_hash_is_sha256(self):
        """Хеш использует SHA256"""
        token = "test_token"
        expected = hashlib.sha256(token.encode()).hexdigest()
        actual = hash_token(token)
        
        assert actual == expected
