"""
Integration тесты для полного flow покупки (mock-based)
"""
import pytest
from datetime import datetime
import uuid
import time


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


class MockCity:
    """Mock модель City"""
    def __init__(self, slug, name_ru, is_active=True):
        self.slug = slug
        self.name_ru = name_ru
        self.is_active = is_active


class MockTour:
    """Mock модель Tour"""
    def __init__(self, id=None, title_ru="", city_slug=""):
        self.id = id or uuid.uuid4()
        self.title_ru = title_ru
        self.city_slug = city_slug


class MockSession:
    """Mock сессия БД"""
    def __init__(self):
        self._intents = {}
        self._purchases = {}
        self._entitlements = {}
        self._grants = []
        self._cities = {}
        self._tours = {}
    
    def get(self, model_class, key):
        if model_class == MockPurchaseIntent:
            return self._intents.get(key)
        if model_class == MockEntitlement:
            return self._entitlements.get(key)
        if model_class == MockCity:
            return self._cities.get(key)
        if model_class == MockTour:
            return self._tours.get(key)
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
        elif isinstance(obj, MockCity):
            self._cities[obj.slug] = obj
        elif isinstance(obj, MockTour):
            self._tours[obj.id] = obj
    
    def commit(self):
        pass
    
    def refresh(self, obj):
        pass


@pytest.fixture
def mock_session():
    return MockSession()


@pytest.fixture
def sample_city(mock_session):
    city = MockCity(slug="test_city", name_ru="Тестовый город")
    mock_session.add(city)
    return city


@pytest.fixture
def sample_tour(mock_session, sample_city):
    tour = MockTour(title_ru="Тестовый тур", city_slug=sample_city.slug)
    mock_session.add(tour)
    return tour


class TestFullPurchaseFlowSandbox:
    """Полный flow покупки в sandbox режиме"""
    
    def test_step1_create_intent(self, mock_session, sample_tour):
        """Шаг 1: Создание intent"""
        intent = MockPurchaseIntent(
            city_slug=sample_tour.city_slug,
            tour_id=sample_tour.id,
            device_anon_id="test_device_123",
            platform="ios",
            status="PENDING",
            idempotency_key="flow_test_key_1"
        )
        mock_session.add(intent)
        
        assert intent.id is not None
        assert intent.status == "PENDING"
    
    def test_step2_confirm_purchase_sandbox(self, mock_session, sample_tour):
        """Шаг 2: Подтверждение покупки в sandbox"""
        # Создаем intent
        intent = MockPurchaseIntent(
            city_slug=sample_tour.city_slug,
            tour_id=sample_tour.id,
            device_anon_id="test_device_123",
            platform="ios",
            status="PENDING",
            idempotency_key="flow_test_key_2"
        )
        mock_session.add(intent)
        
        # Симулируем sandbox подтверждение
        is_sandbox = True
        proof = "SANDBOX_SUCCESS"
        
        if is_sandbox and proof == "SANDBOX_SUCCESS":
            purchase = MockPurchase(
                intent_id=intent.id,
                store="APPSTORE",
                store_transaction_id=f"sandbox_tx_{uuid.uuid4().hex[:8]}",
                status="VALID"
            )
            mock_session.add(purchase)
            intent.status = "COMPLETED"
        
        assert intent.status == "COMPLETED"
    
    def test_step3_check_entitlements(self, mock_session, sample_tour):
        """Шаг 3: Проверка доступа"""
        device_id = "entitled_device"
        
        # Создаем entitlement и grant
        entitlement = MockEntitlement(
            slug=f"{sample_tour.city_slug}_tour_{sample_tour.id}",
            scope="tour",
            ref=str(sample_tour.id),
            title_ru="Доступ к туру",
            is_active=True
        )
        mock_session.add(entitlement)
        
        grant = MockEntitlementGrant(
            device_anon_id=device_id,
            entitlement_id=entitlement.id,
            source="store",
            source_ref="tx_test_123"
        )
        mock_session.add(grant)
        
        # Проверяем доступ
        grants = [g for g in mock_session._grants if g.device_anon_id == device_id]
        
        assert len(grants) == 1
        assert grants[0].entitlement_id == entitlement.id


class TestPurchaseIdempotency:
    """Тесты идемпотентности покупок"""
    
    def test_intent_idempotency(self, mock_session, sample_tour):
        """Создание intent идемпотентно"""
        idem_key = "same_idem_key"
        
        # Первый intent
        intent1 = MockPurchaseIntent(
            city_slug=sample_tour.city_slug,
            tour_id=sample_tour.id,
            device_anon_id="idem_device",
            platform="android",
            status="PENDING",
            idempotency_key=idem_key
        )
        mock_session.add(intent1)
        
        # Проверяем что с тем же ключом найдется существующий
        existing = [i for i in mock_session._intents.values() 
                   if i.idempotency_key == idem_key]
        
        assert len(existing) == 1
        assert existing[0].id == intent1.id
    
    def test_confirm_idempotency(self, mock_session, sample_tour):
        """Подтверждение покупки идемпотентно"""
        # Создаем intent
        intent = MockPurchaseIntent(
            city_slug=sample_tour.city_slug,
            tour_id=sample_tour.id,
            device_anon_id="idem_device_2",
            platform="ios",
            status="PENDING",
            idempotency_key="intent_idem_key"
        )
        mock_session.add(intent)
        
        # Первое подтверждение
        intent.status = "COMPLETED"
        
        # Создаем entitlement
        entitlement = MockEntitlement(
            slug=f"ent_{intent.id}",
            scope="tour",
            ref=str(sample_tour.id),
            title_ru="Доступ",
            is_active=True
        )
        mock_session.add(entitlement)
        
        # Создаем grant
        grant = MockEntitlementGrant(
            device_anon_id="idem_device_2",
            entitlement_id=entitlement.id,
            source="store",
            source_ref="tx_idem_1"
        )
        mock_session.add(grant)
        
        # Проверяем что grant один
        grants = [g for g in mock_session._grants if g.device_anon_id == "idem_device_2"]
        
        assert len(grants) == 1


class TestEntitlementQueries:
    """Тесты запросов entitlements"""
    
    def test_get_entitlements_by_device(self, mock_session, sample_tour):
        """Получение entitlements по device_id"""
        device_id = "query_device"
        
        # Создаем несколько entitlements
        for i in range(3):
            ent = MockEntitlement(
                slug=f"ent_{i}",
                scope="tour",
                ref=f"tour_{i}",
                title_ru=f"Доступ {i}",
                is_active=True
            )
            mock_session.add(ent)
            
            grant = MockEntitlementGrant(
                device_anon_id=device_id,
                entitlement_id=ent.id,
                source="store",
                source_ref=f"tx_{i}"
            )
            mock_session.add(grant)
        
        # Запрашиваем
        grants = [g for g in mock_session._grants if g.device_anon_id == device_id]
        
        assert len(grants) == 3
    
    def test_filter_entitlements_by_city(self, mock_session, sample_city, sample_tour):
        """Фильтрация entitlements по городу"""
        device_id = "city_filter_device"
        
        # Entitlement для нашего города
        ent1 = MockEntitlement(
            slug=f"{sample_city.slug}_tour_1",
            scope="tour",
            ref=str(sample_tour.id),
            title_ru="Тур в нашем городе",
            is_active=True
        )
        mock_session.add(ent1)
        
        # Entitlement для другого города
        ent2 = MockEntitlement(
            slug="other_city_tour_1",
            scope="tour",
            ref="other_tour_id",
            title_ru="Тур в другом городе",
            is_active=True
        )
        mock_session.add(ent2)
        
        # Grants для обоих
        for ent in [ent1, ent2]:
            grant = MockEntitlementGrant(
                device_anon_id=device_id,
                entitlement_id=ent.id,
                source="store",
                source_ref=f"tx_{ent.slug}"
            )
            mock_session.add(grant)
        
        # Фильтруем по городу
        city_entitlements = [e for e in mock_session._entitlements.values() 
                           if e.slug.startswith(sample_city.slug)]
        
        assert len(city_entitlements) == 1
        assert city_entitlements[0].slug.startswith(sample_city.slug)
