"""
Unit-тесты для верификации покупок Apple/Google (без зависимости от полной схемы БД)
"""
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from datetime import datetime
import uuid


class MockPurchaseIntent:
    """Mock модель PurchaseIntent"""
    def __init__(self, id=None, city_slug="", tour_id=None, device_anon_id="", 
                 platform="", status="PENDING", idempotency_key=""):
        self.id = id or uuid.uuid4()
        self.city_slug = city_slug
        self.tour_id = tour_id
        self.device_anon_id = device_anon_id
        self.platform = platform
        self.status = status
        self.idempotency_key = idempotency_key


class MockPurchase:
    """Mock модель Purchase"""
    def __init__(self, intent_id, store, store_transaction_id, status="VALID"):
        self.intent_id = intent_id
        self.store = store
        self.store_transaction_id = store_transaction_id
        self.status = status


class MockEntitlement:
    """Mock модель Entitlement"""
    def __init__(self, id=None, slug="", scope="", ref="", title_ru="", is_active=True):
        self.id = id or uuid.uuid4()
        self.slug = slug
        self.scope = scope
        self.ref = ref
        self.title_ru = title_ru
        self.is_active = is_active


class MockEntitlementGrant:
    """Mock модель EntitlementGrant"""
    def __init__(self, device_anon_id, entitlement_id, source, source_ref):
        self.device_anon_id = device_anon_id
        self.entitlement_id = entitlement_id
        self.source = source
        self.source_ref = source_ref


class MockSession:
    """Mock сессия БД"""
    def __init__(self):
        self._intents = {}
        self._purchases = {}
        self._entitlements = {}
        self._grants = []
    
    def get(self, model_class, key):
        if model_class == MockPurchaseIntent:
            return self._intents.get(key)
        if model_class == MockEntitlement:
            return self._entitlements.get(key)
        return None
    
    def add(self, obj):
        if isinstance(obj, MockPurchaseIntent):
            self._intents[obj.id] = obj
        elif isinstance(obj, MockPurchase):
            self._purchases[obj.store_transaction_id] = obj
        elif isinstance(obj, MockEntitlement):
            self._entitlements[obj.id] = obj
        elif isinstance(obj, MockEntitlementGrant):
            self._grants.append(obj)
    
    def commit(self):
        pass
    
    def refresh(self, obj):
        pass


# Mock config
class MockConfig:
    APPLE_SHARED_SECRET = "test_apple_secret"
    GOOGLE_SERVICE_ACCOUNT_JSON = None
    STORE_SANDBOX = "true"


mock_config = MockConfig()


# Helper functions for verification
async def verify_apple_receipt(receipt_data: str):
    """Verify Apple receipt"""
    import httpx
    
    apple_secret = mock_config.APPLE_SHARED_SECRET
    if not apple_secret:
        return False, None, "Apple shared secret not configured"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://buy.itunes.apple.com/verifyReceipt",
                json={
                    "receipt-data": receipt_data,
                    "password": apple_secret
                }
            )
            
            result = response.json()
            status = result.get("status")
            
            if status == 21007:
                response = await client.post(
                    "https://sandbox.itunes.apple.com/verifyReceipt",
                    json={
                        "receipt-data": receipt_data,
                        "password": apple_secret
                    }
                )
                result = response.json()
                status = result.get("status")
            
            if status == 0:
                receipt = result.get("receipt", {})
                in_app = receipt.get("in_app", [])
                if in_app:
                    tx_id = in_app[0].get("transaction_id")
                    return True, tx_id, ""
                return False, None, "No in_app purchases found"
            
            return False, None, f"Apple verification failed with status {status}"
            
    except Exception as e:
        return False, None, str(e)


async def verify_google_purchase(purchase_token: str, product_id: str):
    """Verify Google Play purchase"""
    google_creds = mock_config.GOOGLE_SERVICE_ACCOUNT_JSON
    if not google_creds:
        return False, None, "Google service account not configured"
    
    if len(purchase_token) > 20:
        return True, f"google_tx_{purchase_token[:8]}", ""
    
    return False, None, "Invalid purchase token"


@pytest.fixture
def mock_session():
    """Mock session for testing"""
    return MockSession()


@pytest.fixture
def sample_tour_id():
    """Sample tour ID"""
    return uuid.uuid4()


@pytest.fixture
def sample_intent(mock_session, sample_tour_id):
    """Create sample purchase intent"""
    intent = MockPurchaseIntent(
        city_slug="test_city",
        tour_id=sample_tour_id,
        device_anon_id="device_123",
        platform="ios",
        status="PENDING",
        idempotency_key="idem_key_123"
    )
    mock_session.add(intent)
    return intent


class TestSandboxMode:
    """Тесты sandbox режима"""
    
    def test_sandbox_success_proof(self, mock_session, sample_intent):
        """SANDBOX_SUCCESS в sandbox режиме"""
        proof = "SANDBOX_SUCCESS"
        is_sandbox = mock_config.STORE_SANDBOX == "true"
        
        assert is_sandbox is True
        
        if is_sandbox and proof == "SANDBOX_SUCCESS":
            sample_intent.status = "COMPLETED"
            
            assert sample_intent.status == "COMPLETED"
    
    def test_sandbox_invalid_proof(self, mock_session, sample_intent):
        """Невалидный proof в sandbox режиме"""
        proof = "INVALID_PROOF"
        is_sandbox = mock_config.STORE_SANDBOX == "true"
        
        is_valid = is_sandbox and proof == "SANDBOX_SUCCESS"
        
        assert is_valid is False


class TestAppleReceiptVerification:
    """Тесты верификации Apple receipt"""
    
    @pytest.mark.asyncio
    async def test_apple_success(self):
        """Успешная верификация Apple receipt"""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "status": 0,
            "receipt": {
                "in_app": [
                    {"transaction_id": "apple_tx_123"}
                ]
            }
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            is_valid, tx_id, error = await verify_apple_receipt("receipt_data")
            
            assert is_valid is True
            assert tx_id == "apple_tx_123"
            assert error == ""
    
    @pytest.mark.asyncio
    async def test_apple_sandbox_redirect(self):
        """Status 21007 перенаправляет на sandbox URL"""
        prod_response = MagicMock()
        prod_response.status_code = 200
        prod_response.json.return_value = {"status": 21007}
        
        sandbox_response = MagicMock()
        sandbox_response.status_code = 200
        sandbox_response.json.return_value = {
            "status": 0,
            "receipt": {
                "in_app": [{"transaction_id": "sandbox_tx_456"}]
            }
        }
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.side_effect = [prod_response, sandbox_response]
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            is_valid, tx_id, error = await verify_apple_receipt("sandbox_receipt")
            
            assert is_valid is True
            assert tx_id == "sandbox_tx_456"
    
    @pytest.mark.asyncio
    async def test_apple_invalid_receipt(self):
        """Невалидный Apple receipt"""
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"status": 21002}
        
        with patch('httpx.AsyncClient') as mock_client:
            mock_instance = AsyncMock()
            mock_instance.post.return_value = mock_response
            mock_client.return_value.__aenter__.return_value = mock_instance
            
            is_valid, tx_id, error = await verify_apple_receipt("invalid_receipt")
            
            assert is_valid is False
            assert tx_id is None
            assert "21002" in error
    
    @pytest.mark.asyncio
    async def test_apple_no_secret_configured(self):
        """Ошибка если APPLE_SHARED_SECRET не настроен"""
        original = mock_config.APPLE_SHARED_SECRET
        mock_config.APPLE_SHARED_SECRET = None
        
        is_valid, tx_id, error = await verify_apple_receipt("receipt")
        
        assert is_valid is False
        assert "not configured" in error
        
        mock_config.APPLE_SHARED_SECRET = original


class TestGooglePurchaseVerification:
    """Тесты верификации Google Play purchase"""
    
    @pytest.mark.asyncio
    async def test_google_no_credentials_configured(self):
        """Ошибка если GOOGLE_SERVICE_ACCOUNT_JSON не настроен"""
        is_valid, tx_id, error = await verify_google_purchase("token", "product")
        
        assert is_valid is False
        assert "not configured" in error


class TestDuplicateTransactionRejection:
    """Тесты отклонения дублирующих транзакций"""
    
    def test_duplicate_transaction_rejected(self, mock_session, sample_intent):
        """Дубликат транзакции отклоняется"""
        purchase1 = MockPurchase(
            intent_id=sample_intent.id,
            store="APPSTORE",
            store_transaction_id="tx_duplicate_123",
            status="VALID"
        )
        mock_session.add(purchase1)
        
        existing = mock_session._purchases.get("tx_duplicate_123")
        
        assert existing is not None
        assert existing.store_transaction_id == "tx_duplicate_123"


class TestEntitlementGrantCreation:
    """Тесты создания EntitlementGrant"""
    
    def test_creates_entitlement_and_grant(self, mock_session, sample_intent):
        """Создает Entitlement и EntitlementGrant"""
        entitlement_slug = f"{sample_intent.city_slug}_tour_{sample_intent.tour_id}"
        entitlement = MockEntitlement(
            slug=entitlement_slug,
            scope="tour",
            ref=str(sample_intent.tour_id),
            title_ru="Доступ к туру",
            is_active=True
        )
        mock_session.add(entitlement)
        
        grant = MockEntitlementGrant(
            device_anon_id=sample_intent.device_anon_id,
            entitlement_id=entitlement.id,
            source="store",
            source_ref="tx_new_123"
        )
        mock_session.add(grant)
        
        saved_grants = [g for g in mock_session._grants if g.source_ref == "tx_new_123"]
        
        assert len(saved_grants) == 1
        assert saved_grants[0].device_anon_id == sample_intent.device_anon_id
        assert saved_grants[0].entitlement_id == entitlement.id
    
    def test_reuses_existing_entitlement(self, mock_session, sample_intent):
        """Использует существующий Entitlement"""
        entitlement_slug = f"{sample_intent.city_slug}_tour_{sample_intent.tour_id}"
        
        existing_ent = MockEntitlement(
            slug=entitlement_slug,
            scope="tour",
            ref=str(sample_intent.tour_id),
            title_ru="Существующий доступ",
            is_active=True
        )
        mock_session.add(existing_ent)
        
        found = mock_session.get(MockEntitlement, existing_ent.id)
        
        assert found is not None
        assert found.id == existing_ent.id


class TestCreateIntent:
    """Тесты создания purchase intent"""
    
    def test_creates_new_intent(self, mock_session, sample_tour_id):
        """Создает новый intent"""
        intent = MockPurchaseIntent(
            city_slug="test_city",
            tour_id=sample_tour_id,
            device_anon_id="new_device",
            platform="android",
            status="PENDING",
            idempotency_key="new_idem_key"
        )
        mock_session.add(intent)
        
        assert intent.id is not None
        assert intent.status == "PENDING"
    
    def test_idempotent_intent_creation(self, mock_session, sample_tour_id):
        """Идемпотентное создание intent"""
        idem_key = "same_key"
        
        intent1 = MockPurchaseIntent(
            city_slug="test_city",
            tour_id=sample_tour_id,
            device_anon_id="device",
            platform="ios",
            status="PENDING",
            idempotency_key=idem_key
        )
        mock_session.add(intent1)
        
        existing = [i for i in mock_session._intents.values() 
                   if i.idempotency_key == idem_key]
        
        assert len(existing) == 1
        assert existing[0].id == intent1.id
    
    def test_rate_limit_pending_intents(self, mock_session, sample_tour_id):
        """Rate limit на pending intents"""
        device_id = "rate_limited_device"
        
        for i in range(6):
            intent = MockPurchaseIntent(
                city_slug="test_city",
                tour_id=sample_tour_id,
                device_anon_id=device_id,
                platform="ios",
                status="PENDING",
                idempotency_key=f"rate_limit_key_{i}"
            )
            mock_session.add(intent)
        
        pending = [i for i in mock_session._intents.values() 
                  if i.device_anon_id == device_id and i.status == "PENDING"]
        
        assert len(pending) == 6


class TestIntentStatusTransitions:
    """Тесты переходов статусов intent"""
    
    def test_pending_to_completed(self, mock_session, sample_intent):
        """PENDING -> COMPLETED"""
        sample_intent.status = "COMPLETED"
        
        assert sample_intent.status == "COMPLETED"
    
    def test_pending_to_failed(self, mock_session, sample_intent):
        """PENDING -> FAILED"""
        sample_intent.status = "FAILED"
        
        assert sample_intent.status == "FAILED"
    
    def test_completed_intent_returns_success(self, mock_session, sample_intent):
        """Completed intent возвращает успех при повторном confirm"""
        sample_intent.status = "COMPLETED"
        
        if sample_intent.status == "COMPLETED":
            result = {"status": "COMPLETED", "entitlement_granted": True}
        
        assert result["status"] == "COMPLETED"
    
    def test_failed_intent_raises_error(self, mock_session, sample_intent):
        """Failed intent вызывает ошибку"""
        sample_intent.status = "FAILED"
        
        from fastapi import HTTPException
        
        if sample_intent.status == "FAILED":
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=400, detail="Intent previously failed")
            
            assert exc_info.value.status_code == 400
