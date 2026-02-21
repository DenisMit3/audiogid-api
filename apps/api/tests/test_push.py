"""
Unit-тесты для Push-уведомлений API (без зависимости от полной схемы БД)
"""
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime
import uuid
import json


class MockPushToken:
    """Mock модель UserPushToken"""
    def __init__(self, token: str, device_id: str, platform: str, user_id: uuid.UUID = None):
        self.token = token
        self.device_id = device_id
        self.platform = platform
        self.user_id = user_id


class MockAppSettings:
    """Mock модель AppSettings"""
    def __init__(self, key: str, value: str):
        self.key = key
        self.value = value


class MockSession:
    """Mock сессия БД"""
    def __init__(self):
        self._tokens = {}
        self._settings = {}
    
    def get(self, model_class, key):
        if model_class == MockPushToken:
            return self._tokens.get(key)
        return self._settings.get(key)
    
    def add(self, obj):
        if isinstance(obj, MockPushToken):
            self._tokens[obj.token] = obj
        elif isinstance(obj, MockAppSettings):
            self._settings[obj.key] = obj
    
    def delete(self, obj):
        if isinstance(obj, MockPushToken):
            del self._tokens[obj.token]
    
    def query(self, model_class):
        return MockQuery(self._tokens if model_class == MockPushToken else self._settings)
    
    def commit(self):
        pass


class MockQuery:
    """Mock query"""
    def __init__(self, storage):
        self._storage = storage
        self._platform_filter = None
        self._user_filter = None
    
    def filter(self, *args):
        return self
    
    def all(self):
        results = list(self._storage.values())
        if self._platform_filter:
            results = [t for t in results if t.platform == self._platform_filter]
        if self._user_filter:
            results = [t for t in results if t.user_id == self._user_filter]
        return results


# Helper functions
def get_fcm_key(session) -> str:
    """Get FCM key from settings"""
    setting = session.get(MockAppSettings, "notifications.fcm_server_key")
    if not setting:
        return None
    try:
        return json.loads(setting.value)
    except (json.JSONDecodeError, TypeError):
        return setting.value


async def send_fcm_message(fcm_key: str, token: str, title: str, body: str, data: dict = None):
    """Send FCM message"""
    import httpx
    
    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "to": token,
                "notification": {"title": title, "body": body}
            }
            if data:
                payload["data"] = data
            
            response = await client.post(
                "https://fcm.googleapis.com/fcm/send",
                headers={
                    "Authorization": f"key={fcm_key}",
                    "Content-Type": "application/json"
                },
                json=payload
            )
            
            if response.status_code != 200:
                return False, f"HTTP {response.status_code}"
            
            result = response.json()
            if result.get("success", 0) > 0:
                return True, ""
            
            error = result.get("results", [{}])[0].get("error", "Unknown error")
            return False, error
            
    except Exception as e:
        return False, str(e)


@pytest.fixture
def mock_session():
    """Mock session for testing"""
    return MockSession()


@pytest.fixture
def admin_user_id():
    """Admin user ID"""
    return uuid.uuid4()


@pytest.fixture
def sample_push_tokens(mock_session):
    """Create sample push tokens"""
    tokens = [
        MockPushToken(token="token_android_1", device_id="device_1", platform="android"),
        MockPushToken(token="token_android_2", device_id="device_2", platform="android"),
        MockPushToken(token="token_ios_1", device_id="device_3", platform="ios"),
        MockPushToken(token="token_unknown", device_id="device_4", platform="unknown"),
    ]
    for t in tokens:
        mock_session.add(t)
    return tokens


class TestRegisterPushToken:
    """Тесты регистрации push-токенов"""
    
    def test_register_new_token(self, mock_session):
        """Регистрация нового токена"""
        token = MockPushToken(
            token="new_token_123",
            device_id="device_abc",
            platform="android"
        )
        mock_session.add(token)
        
        saved = mock_session.get(MockPushToken, "new_token_123")
        assert saved is not None
        assert saved.device_id == "device_abc"
        assert saved.platform == "android"
        assert saved.user_id is None
    
    def test_register_token_with_user(self, mock_session, admin_user_id):
        """Регистрация токена с привязкой к пользователю"""
        token = MockPushToken(
            token="user_token_123",
            device_id="device_xyz",
            platform="ios",
            user_id=admin_user_id
        )
        mock_session.add(token)
        
        saved = mock_session.get(MockPushToken, "user_token_123")
        assert saved.user_id == admin_user_id
    
    def test_update_existing_token(self, mock_session, admin_user_id):
        """Обновление существующего токена"""
        existing = MockPushToken(
            token="existing_token",
            device_id="old_device",
            platform="android",
            user_id=None
        )
        mock_session.add(existing)
        
        existing.device_id = "new_device"
        existing.user_id = admin_user_id
        
        saved = mock_session.get(MockPushToken, "existing_token")
        assert saved.device_id == "new_device"
        assert saved.user_id == admin_user_id


class TestGetFCMKey:
    """Тесты получения FCM ключа"""
    
    def test_returns_none_if_not_configured(self, mock_session):
        """Возвращает None если ключ не настроен"""
        result = get_fcm_key(mock_session)
        assert result is None
    
    def test_returns_key_from_settings(self, mock_session):
        """Возвращает ключ из настроек"""
        mock_session.add(MockAppSettings(
            key="notifications.fcm_server_key",
            value='"test_fcm_key_123"'
        ))
        
        result = get_fcm_key(mock_session)
        assert result == "test_fcm_key_123"
    
    def test_returns_raw_string_if_not_json(self, mock_session):
        """Возвращает строку если не JSON"""
        mock_session.add(MockAppSettings(
            key="notifications.fcm_server_key",
            value="raw_key_value"
        ))
        
        result = get_fcm_key(mock_session)
        assert result == "raw_key_value"


class TestSendFCMMessage:
    """Тесты отправки FCM сообщений"""
    
    @pytest.mark.asyncio
    async def test_send_success(self):
        """Успешная отправка"""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"success": 1, "results": [{}]}
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            success, error = await send_fcm_message(
                "fcm_key", "device_token", "Title", "Body"
            )
            
            assert success is True
            assert error == ""
    
    @pytest.mark.asyncio
    async def test_send_with_data(self):
        """Отправка с дополнительными данными"""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"success": 1, "results": [{}]}
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            success, error = await send_fcm_message(
                "fcm_key", "device_token", "Title", "Body",
                data={"action": "open_tour", "tour_id": "123"}
            )
            
            assert success is True
            
            call_args = mock_instance.post.call_args
            payload = call_args.kwargs.get('json', {})
            assert "data" in payload
    
    @pytest.mark.asyncio
    async def test_send_failure_not_registered(self):
        """Ошибка - токен не зарегистрирован"""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "success": 0, 
            "results": [{"error": "NotRegistered"}]
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            success, error = await send_fcm_message(
                "fcm_key", "invalid_token", "Title", "Body"
            )
            
            assert success is False
            assert error == "NotRegistered"
    
    @pytest.mark.asyncio
    async def test_send_http_error(self):
        """HTTP ошибка"""
        mock_response = MagicMock()
        mock_response.status_code = 401
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            success, error = await send_fcm_message(
                "invalid_key", "token", "Title", "Body"
            )
            
            assert success is False
            assert "401" in error
    
    @pytest.mark.asyncio
    async def test_send_network_error(self):
        """Сетевая ошибка"""
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.side_effect = Exception("Network error")
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            success, error = await send_fcm_message(
                "fcm_key", "token", "Title", "Body"
            )
            
            assert success is False
            assert "Network error" in error


class TestPushStats:
    """Тесты статистики push-токенов"""
    
    def test_counts_by_platform(self, mock_session, sample_push_tokens):
        """Подсчет токенов по платформам"""
        all_tokens = list(mock_session._tokens.values())
        
        android_count = sum(1 for t in all_tokens if t.platform == "android")
        ios_count = sum(1 for t in all_tokens if t.platform == "ios")
        unknown_count = sum(1 for t in all_tokens if t.platform not in ["android", "ios"])
        
        assert android_count == 2
        assert ios_count == 1
        assert unknown_count == 1
        assert len(all_tokens) == 4


class TestPushTargetFiltering:
    """Тесты фильтрации целевых устройств"""
    
    def test_filter_android_only(self, mock_session, sample_push_tokens):
        """Фильтр только Android"""
        tokens = [t for t in mock_session._tokens.values() if t.platform == "android"]
        
        assert len(tokens) == 2
        assert all(t.platform == "android" for t in tokens)
    
    def test_filter_ios_only(self, mock_session, sample_push_tokens):
        """Фильтр только iOS"""
        tokens = [t for t in mock_session._tokens.values() if t.platform == "ios"]
        
        assert len(tokens) == 1
        assert tokens[0].platform == "ios"
    
    def test_filter_by_user_id(self, mock_session, admin_user_id):
        """Фильтр по user_id"""
        mock_session.add(MockPushToken(
            token="user_specific_token",
            device_id="device",
            platform="android",
            user_id=admin_user_id
        ))
        
        tokens = [t for t in mock_session._tokens.values() if t.user_id == admin_user_id]
        
        assert len(tokens) == 1
        assert tokens[0].token == "user_specific_token"
    
    def test_filter_all(self, mock_session, sample_push_tokens):
        """Без фильтра - все токены"""
        tokens = list(mock_session._tokens.values())
        assert len(tokens) == 4


class TestInvalidTokensCleanup:
    """Тесты удаления невалидных токенов"""
    
    def test_removes_not_registered_token(self, mock_session):
        """Удаление токена с ошибкой NotRegistered"""
        mock_session.add(MockPushToken(
            token="invalid_token",
            device_id="device",
            platform="android"
        ))
        
        invalid_tokens = ["invalid_token"]
        for token in invalid_tokens:
            t = mock_session.get(MockPushToken, token)
            if t:
                mock_session.delete(t)
        
        assert mock_session.get(MockPushToken, "invalid_token") is None
    
    def test_keeps_valid_tokens(self, mock_session, sample_push_tokens):
        """Валидные токены сохраняются"""
        invalid_tokens = []
        
        for token in invalid_tokens:
            t = mock_session.get(MockPushToken, token)
            if t:
                mock_session.delete(t)
        
        all_tokens = list(mock_session._tokens.values())
        assert len(all_tokens) == 4
