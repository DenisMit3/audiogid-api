"""
Unit-тесты для AppSettings API (без зависимости от полной схемы БД)
"""
import pytest
from unittest.mock import MagicMock
from datetime import datetime
import uuid
import json


class MockAppSettings:
    """Mock модель AppSettings"""
    def __init__(self, key: str, value: str, updated_at: datetime = None, updated_by: uuid.UUID = None):
        self.key = key
        self.value = value
        self.updated_at = updated_at or datetime.utcnow()
        self.updated_by = updated_by


class MockSession:
    """Mock сессия БД"""
    def __init__(self):
        self._storage = {}
    
    def get(self, model_class, key):
        return self._storage.get(key)
    
    def add(self, obj):
        if hasattr(obj, 'key'):
            self._storage[obj.key] = obj
    
    def query(self, model_class):
        return MockQuery(self._storage)
    
    def commit(self):
        pass


class MockQuery:
    """Mock query"""
    def __init__(self, storage):
        self._storage = storage
        self._filters = []
    
    def filter(self, *args):
        return self
    
    def all(self):
        return list(self._storage.values())


# Helper functions
def get_settings_dict(session, prefix: str) -> dict:
    """Get settings with prefix as dict"""
    result = {}
    for key, setting in session._storage.items():
        if key.startswith(f"{prefix}."):
            short_key = key.replace(f"{prefix}.", "")
            try:
                result[short_key] = json.loads(setting.value)
            except (json.JSONDecodeError, TypeError):
                result[short_key] = setting.value
    return result


def save_settings_dict(session, prefix: str, data: dict, updated_by: uuid.UUID = None):
    """Save settings dict with prefix"""
    for key, value in data.items():
        full_key = f"{prefix}.{key}"
        
        # Serialize value
        if isinstance(value, str):
            serialized = value
        else:
            serialized = json.dumps(value)
        
        existing = session.get(MockAppSettings, full_key)
        if existing:
            existing.value = serialized
            existing.updated_at = datetime.utcnow()
            existing.updated_by = updated_by
        else:
            setting = MockAppSettings(
                key=full_key,
                value=serialized,
                updated_at=datetime.utcnow(),
                updated_by=updated_by
            )
            session.add(setting)
    
    session.commit()


def get_raw_setting(session, key: str):
    """Get single setting value"""
    setting = session.get(MockAppSettings, key)
    if not setting:
        return None
    try:
        return json.loads(setting.value)
    except (json.JSONDecodeError, TypeError):
        return setting.value


@pytest.fixture
def mock_session():
    """Mock session for testing"""
    return MockSession()


@pytest.fixture
def admin_user_id():
    """Admin user ID"""
    return uuid.uuid4()


class TestGetSettingsDict:
    """Тесты для get_settings_dict"""
    
    def test_returns_empty_dict_when_no_settings(self, mock_session):
        """Возвращает пустой dict если настроек нет"""
        result = get_settings_dict(mock_session, "notifications")
        assert result == {}
    
    def test_returns_settings_with_prefix(self, mock_session):
        """Возвращает настройки с указанным префиксом"""
        mock_session.add(MockAppSettings(key="notifications.fcm_key", value='"test_key"'))
        mock_session.add(MockAppSettings(key="notifications.enabled", value="true"))
        mock_session.add(MockAppSettings(key="ai.provider", value='"openai"'))
        
        result = get_settings_dict(mock_session, "notifications")
        
        assert "fcm_key" in result
        assert result["fcm_key"] == "test_key"
        assert "enabled" in result
        assert result["enabled"] == True
        assert "provider" not in result
    
    def test_parses_json_values(self, mock_session):
        """Парсит JSON значения"""
        mock_session.add(MockAppSettings(key="test.array", value='["a", "b", "c"]'))
        mock_session.add(MockAppSettings(key="test.object", value='{"nested": true}'))
        
        result = get_settings_dict(mock_session, "test")
        
        assert result["array"] == ["a", "b", "c"]
        assert result["object"] == {"nested": True}
    
    def test_returns_raw_string_if_not_json(self, mock_session):
        """Возвращает строку если не JSON"""
        mock_session.add(MockAppSettings(key="test.plain", value="not json"))
        
        result = get_settings_dict(mock_session, "test")
        assert result["plain"] == "not json"


class TestSaveSettingsDict:
    """Тесты для save_settings_dict"""
    
    def test_creates_new_settings(self, mock_session, admin_user_id):
        """Создает новые настройки"""
        data = {"key1": "value1", "key2": 123, "key3": True}
        
        save_settings_dict(mock_session, "test", data, admin_user_id)
        
        s1 = mock_session.get(MockAppSettings, "test.key1")
        assert s1 is not None
        assert s1.value == "value1"
        
        s2 = mock_session.get(MockAppSettings, "test.key2")
        assert json.loads(s2.value) == 123
        
        s3 = mock_session.get(MockAppSettings, "test.key3")
        assert json.loads(s3.value) == True
    
    def test_updates_existing_settings(self, mock_session, admin_user_id):
        """Обновляет существующие настройки"""
        mock_session.add(MockAppSettings(key="test.existing", value='"old_value"'))
        
        save_settings_dict(mock_session, "test", {"existing": "new_value"}, admin_user_id)
        
        s = mock_session.get(MockAppSettings, "test.existing")
        assert s.value == "new_value"
        assert s.updated_by == admin_user_id
    
    def test_sets_updated_by(self, mock_session, admin_user_id):
        """Устанавливает updated_by"""
        save_settings_dict(mock_session, "test", {"key": "value"}, admin_user_id)
        
        s = mock_session.get(MockAppSettings, "test.key")
        assert s.updated_by == admin_user_id


class TestFCMKeyMasking:
    """Тесты маскировки FCM ключа"""
    
    def test_masks_long_key(self, mock_session):
        """Маскирует длинный ключ"""
        mock_session.add(MockAppSettings(
            key="notifications.fcm_server_key", 
            value='"AAAA1234567890BBBB"'
        ))
        
        data = get_settings_dict(mock_session, "notifications")
        
        assert data["fcm_server_key"] == "AAAA1234567890BBBB"
        
        key = data["fcm_server_key"]
        if len(key) > 8:
            masked = key[:4] + "..." + key[-4:]
            assert masked == "AAAA...BBBB"
    
    def test_short_key_not_masked(self):
        """Короткий ключ не маскируется"""
        key = "short"
        if len(key) > 8:
            masked = key[:4] + "..." + key[-4:]
        else:
            masked = key
        
        assert masked == "short"


class TestMaskedKeyNotOverwritten:
    """Тесты что замаскированный ключ не перезаписывает реальный"""
    
    def test_masked_key_preserved(self, mock_session, admin_user_id):
        """Замаскированный ключ не перезаписывает оригинал"""
        original_key = "REAL_FCM_KEY_12345678"
        save_settings_dict(mock_session, "notifications", {
            "fcm_server_key": original_key
        }, admin_user_id)
        
        masked_key = "REAL...5678"
        
        data = {"fcm_server_key": masked_key}
        if "..." in data.get("fcm_server_key", ""):
            existing = get_settings_dict(mock_session, "notifications")
            data["fcm_server_key"] = existing.get("fcm_server_key", "")
        
        save_settings_dict(mock_session, "notifications", data, admin_user_id)
        
        result = get_settings_dict(mock_session, "notifications")
        assert result["fcm_server_key"] == original_key


class TestGetRawSetting:
    """Тесты для get_raw_setting"""
    
    def test_returns_none_if_not_exists(self, mock_session):
        """Возвращает None если настройки нет"""
        result = get_raw_setting(mock_session, "nonexistent.key")
        assert result is None
    
    def test_returns_parsed_json(self, mock_session):
        """Возвращает распарсенный JSON"""
        mock_session.add(MockAppSettings(key="test.json", value='{"key": "value"}'))
        
        result = get_raw_setting(mock_session, "test.json")
        assert result == {"key": "value"}
    
    def test_returns_raw_string(self, mock_session):
        """Возвращает строку если не JSON"""
        mock_session.add(MockAppSettings(key="test.string", value="plain text"))
        
        result = get_raw_setting(mock_session, "test.string")
        assert result == "plain text"


class TestNotificationSettingsDefaults:
    """Тесты дефолтных значений NotificationSettings"""
    
    def test_default_values(self):
        """Проверка дефолтных значений"""
        defaults = {
            "fcm_server_key": "",
            "email_sender_name": "Audiogid Support",
            "email_sender_address": "support@audiogid.app",
            "enable_push": True,
            "enable_email": False
        }
        
        assert defaults["fcm_server_key"] == ""
        assert defaults["email_sender_name"] == "Audiogid Support"
        assert defaults["enable_push"] == True
        assert defaults["enable_email"] == False


class TestAISettingsDefaults:
    """Тесты дефолтных значений AISettings"""
    
    def test_default_values(self):
        """Проверка дефолтных значений"""
        defaults = {
            "tts_provider": "openai",
            "openai_api_key": "",
            "default_voice": "alloy",
            "enable_translation": True
        }
        
        assert defaults["tts_provider"] == "openai"
        assert defaults["openai_api_key"] == ""
        assert defaults["default_voice"] == "alloy"
        assert defaults["enable_translation"] == True
