
import pytest
import uuid
from sqlmodel import Session, select
from apps.api.api.core.models import Entitlement, EntitlementGrant, User
from apps.api.api.billing.router import batch_purchase, BatchPurchaseRequest

@pytest.mark.asyncio
async def test_batch_purchase_empty(db_session: Session):
    req = BatchPurchaseRequest(poi_ids=[], tour_ids=[], device_anon_id="dev-1")
    # router dependency injection usually handles Session/User, here we pass explicitly
    res = await batch_purchase(req, session=db_session, user=None)
    assert res.product_ids == []
    assert res.already_owned == []

@pytest.mark.asyncio
async def test_batch_purchase_filtering(db_session: Session):
    # Setup Data
    p1_uuid = str(uuid.uuid4())
    t1_uuid = str(uuid.uuid4())
    t2_uuid = str(uuid.uuid4())

    # Entitlements
    e1 = Entitlement(slug="sku_p1", ref=p1_uuid, scope="poi", title_ru="P1", is_active=True)
    e2 = Entitlement(slug="sku_t1", ref=t1_uuid, scope="tour", title_ru="T1", is_active=True)
    e3 = Entitlement(slug="sku_t2", ref=t2_uuid, scope="tour", title_ru="T2", is_active=True)
    db_session.add(e1)
    db_session.add(e2)
    db_session.add(e3)
    db_session.commit()
    db_session.refresh(e1)

    # Grant e1 (p1) to dev-1
    g1 = EntitlementGrant(
        device_anon_id="dev-1",
        entitlement_id=e1.id,
        source="promo",
        source_ref="promo_123"
    )
    db_session.add(g1)
    db_session.commit()

    # Request: Buy p1, t1, t2 for dev-1
    req = BatchPurchaseRequest(
        poi_ids=[uuid.UUID(p1_uuid)],
        tour_ids=[uuid.UUID(t1_uuid), uuid.UUID(t2_uuid)],
        device_anon_id="dev-1"
    )

    res = await batch_purchase(req, session=db_session, user=None)

    # p1 is owned
    assert p1_uuid in res.already_owned
    assert len(res.already_owned) == 1

    # t1, t2 are needed
    # product_ids should be slugs
    assert "sku_t1" in res.product_ids
    assert "sku_t2" in res.product_ids
    assert len(res.product_ids) == 2

@pytest.mark.asyncio
async def test_batch_purchase_user_cross_device(db_session: Session):
    # User u1 has grant on Device A.
    # Request comes from Device B, but authenticated as u1.
    # Should see ownership.

    u1 = User(id=uuid.uuid4(), role="user")
    db_session.add(u1)
    
    t1_uuid = str(uuid.uuid4())
    e1 = Entitlement(slug="sku_t1", ref=t1_uuid, scope="tour", title_ru="T1", is_active=True)
    db_session.add(e1)
    db_session.commit()
    db_session.refresh(e1)

    # Grant to User u1 (device_anon_id refers to where they bought it, e.g. "dev-A")
    g1 = EntitlementGrant(
        device_anon_id="dev-A",
        user_id=u1.id,
        entitlement_id=e1.id,
        source="store",
        source_ref="tx_1"
    )
    db_session.add(g1)
    db_session.commit()

    # Check from Dev B with User u1
    req = BatchPurchaseRequest(
        poi_ids=[],
        tour_ids=[uuid.UUID(t1_uuid)],
        device_anon_id="dev-B"
    )

    res = await batch_purchase(req, session=db_session, user=u1)
    
    # Should be owned because user matches
    assert t1_uuid in res.already_owned
    assert res.product_ids == []

@pytest.mark.asyncio
async def test_batch_purchase_device_only(db_session: Session):
    # Grant on dev-A. Request on dev-A. No user. Should work.
    
    t1_uuid = str(uuid.uuid4())
    e1 = Entitlement(slug="sku_t1", ref=t1_uuid, scope="tour", title_ru="T1", is_active=True)
    db_session.add(e1)
    db_session.commit()
    db_session.refresh(e1)

    g1 = EntitlementGrant(
        device_anon_id="dev-A",
        entitlement_id=e1.id,
        source="store",
        source_ref="tx_1"
    )
    db_session.add(g1)
    db_session.commit()

    req = BatchPurchaseRequest(
        poi_ids=[],
        tour_ids=[uuid.UUID(t1_uuid)],
        device_anon_id="dev-A"
    )
    
    res = await batch_purchase(req, session=db_session, user=None)
    assert t1_uuid in res.already_owned

