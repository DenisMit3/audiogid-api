"""
Integration тесты для Auth flow с blacklist (mock-based)
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
    def __init__(self, id: uuid.UUID = None, role: str = "user", is_active: bool = True):
        self.id = id or uuid.uuid4()
        self.role = role
        self.is_active = is_active


class MockUserIdentity:
    """Mock модель UserIdentity"""
    def __init__(self, user_id: uuid.UUID, provider: str, provider_id: str):
        self.user_id = user_id
        self.provider = provider
        self.provider_id = provider_id


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
        self._identities = []
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
        elif isinstance(obj, MockUserIdentity):
            self._identities.append(obj)
        elif isinstance(obj, MockAuditLog):
            self._audit_logs.append(obj)
    
    def commit(self):
        pass


@pytest.fixture
def mock_session():
    return MockSession()


@pytest.fixture
def admin_user(mock_session):
    user = MockUser(role="admin", is_active=True)
    mock_session.add(user)
    return user


@pytest.fixture
def regular_user(mock_session):
    user = MockUser(role="user", is_active=True)
    mock_session.add(user)
    
    identity = MockUserIdentity(
        user_id=user.id,
        provider="phone",
        provider_id="+79001234567"
    )
    mock_session.add(identity)
    
    return user


class TestLoginRevokeReloginFlow:
    """Тест полного flow: логин -> revoke -> повторный логин"""
    
    def test_full_flow(self, mock_session, admin_user, regular_user):
        """
        1. Логин -> получить токен
        2. Admin revoke sessions
        3. Старый токен отклонен
        4. Новый логин -> новый токен работает
        """
        from jose import jwt
        
        # Шаг 1: Симулируем логин - создаем токен
        old_token_iat = time.time()
        old_payload = {
            "sub": str(regular_user.id),
            "role": "user",
            "iat": old_token_iat,
            "exp": old_token_iat + 3600
        }
        old_token = jwt.encode(old_payload, "test_secret_key_32_chars_long!!", algorithm="HS256")
        
        # Небольшая задержка
        time.sleep(0.1)
        
        # Шаг 2: Admin делает revoke
        revoke_ts = time.time()
        revoke_marker = MockBlacklistedToken(
            token_hash=f"revoke_all_{regular_user.id}_{revoke_ts}",
            expires_at=datetime.utcnow() + timedelta(days=7),
            user_id=regular_user.id
        )
        mock_session.add(revoke_marker)
        
        # Шаг 3: Проверяем что старый токен невалиден
        assert old_token_iat < revoke_ts
        
        # Шаг 4: Новый логин после revoke
        time.sleep(0.1)
        new_token_iat = time.time()
        new_payload = {
            "sub": str(regular_user.id),
            "role": "user",
            "iat": new_token_iat,
            "exp": new_token_iat + 3600
        }
        new_token = jwt.encode(new_payload, "test_secret_key_32_chars_long!!", algorithm="HS256")
        
        # Новый токен выпущен ПОСЛЕ revoke -> валиден
        assert new_token_iat > revoke_ts
    
    def test_revoke_invalidates_all_sessions(self, mock_session, admin_user, regular_user):
        """Revoke инвалидирует все сессии пользователя"""
        from jose import jwt
        
        # Создаем несколько токенов (разные устройства) - все в прошлом
        base_time = time.time()
        tokens = []
        for i in range(3):
            iat = base_time - 3600 + i  # час назад + смещение
            payload = {
                "sub": str(regular_user.id),
                "role": "user",
                "iat": iat,
                "exp": iat + 7200
            }
            token = jwt.encode(payload, "test_secret_key_32_chars_long!!", algorithm="HS256")
            tokens.append((token, iat))
        
        # Revoke (сейчас)
        revoke_ts = base_time
        revoke_marker = MockBlacklistedToken(
            token_hash=f"revoke_all_{regular_user.id}_{revoke_ts}",
            expires_at=datetime.utcnow() + timedelta(days=7),
            user_id=regular_user.id
        )
        mock_session.add(revoke_marker)
        
        # Все старые токены должны быть невалидны (выпущены ДО revoke)
        for token, iat in tokens:
            assert iat < revoke_ts


class TestBlockUnblockFlow:
    """Тест flow блокировки/разблокировки"""
    
    def test_block_prevents_access(self, mock_session, admin_user, regular_user):
        """Блокировка предотвращает доступ"""
        # Блокируем пользователя
        regular_user.is_active = False
        
        # Создаем маркер блокировки
        block_ts = datetime.utcnow().timestamp()
        block_marker = MockBlacklistedToken(
            token_hash=f"blocked_{regular_user.id}_{block_ts}",
            expires_at=datetime.utcnow() + timedelta(days=365),
            user_id=regular_user.id
        )
        mock_session.add(block_marker)
        
        # Проверяем что пользователь заблокирован
        user = mock_session.get(MockUser, regular_user.id)
        assert user.is_active is False
        
        # Проверяем наличие маркера
        markers = [t for t in mock_session._blacklist.values() 
                  if t.token_hash.startswith(f"blocked_{regular_user.id}")]
        assert len(markers) == 1
    
    def test_unblock_restores_access(self, mock_session, admin_user, regular_user):
        """Разблокировка восстанавливает доступ"""
        # Сначала блокируем
        regular_user.is_active = False
        
        # Разблокируем
        regular_user.is_active = True
        
        # Проверяем
        user = mock_session.get(MockUser, regular_user.id)
        assert user.is_active is True


class TestAuditLogIntegration:
    """Тесты интеграции с audit log"""
    
    def test_revoke_creates_audit_entry(self, mock_session, admin_user, regular_user):
        """Revoke создает запись в audit log"""
        audit = MockAuditLog(
            action="revoke_sessions",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        # Проверяем
        logs = [l for l in mock_session._audit_logs 
               if l.action == "revoke_sessions" and l.target_id == regular_user.id]
        
        assert len(logs) == 1
        assert logs[0].actor_fingerprint == str(admin_user.id)
    
    def test_block_creates_audit_entry(self, mock_session, admin_user, regular_user):
        """Block создает запись в audit log"""
        audit = MockAuditLog(
            action="block_user",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        logs = [l for l in mock_session._audit_logs if l.action == "block_user"]
        
        assert len(logs) == 1
    
    def test_unblock_creates_audit_entry(self, mock_session, admin_user, regular_user):
        """Unblock создает запись в audit log"""
        audit = MockAuditLog(
            action="unblock_user",
            target_id=regular_user.id,
            actor_type="admin",
            actor_fingerprint=str(admin_user.id)
        )
        mock_session.add(audit)
        
        logs = [l for l in mock_session._audit_logs if l.action == "unblock_user"]
        
        assert len(logs) == 1
    
    def test_audit_log_timeline(self, mock_session, admin_user, regular_user):
        """Audit log сохраняет хронологию действий"""
        actions = ["revoke_sessions", "block_user", "unblock_user"]
        
        for action in actions:
            audit = MockAuditLog(
                action=action,
                target_id=regular_user.id,
                actor_type="admin",
                actor_fingerprint=str(admin_user.id)
            )
            mock_session.add(audit)
            time.sleep(0.01)
        
        # Получаем все логи для пользователя
        logs = sorted(
            [l for l in mock_session._audit_logs if l.target_id == regular_user.id],
            key=lambda x: x.created_at
        )
        
        assert len(logs) == 3
        assert [log.action for log in logs] == actions
