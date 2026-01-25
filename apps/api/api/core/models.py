from typing import Optional, List, Any
from sqlmodel import Field, SQLModel, Relationship
from sqlalchemy import Column
from geoalchemy2 import Geography
from datetime import datetime
import uuid

# --- Previous Models ---
class CityBase(SQLModel):
    slug: str = Field(index=True, unique=True)
    name_ru: str
    is_active: bool = Field(default=True)

class City(CityBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tours: List["Tour"] = Relationship(back_populates="city")
    pois: List["Poi"] = Relationship(back_populates="city")

class PoiBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    description_ru: Optional[str] = None 
    published_at: Optional[datetime] = Field(default=None, index=True)
    lat: Optional[float] = Field(default=None)
    lon: Optional[float] = Field(default=None)
    osm_id: Optional[str] = Field(default=None, index=True)
    wikidata_id: Optional[str] = Field(default=None, index=True)
    confidence_score: float = Field(default=0.0)

class Poi(PoiBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    geo: Any = Field(sa_column=Column(Geography("POINT", srid=4326, spatial_index=True)), default=None)
    city: Optional[City] = Relationship(back_populates="pois")
    tour_items: List["TourItem"] = Relationship(back_populates="poi")
    sources: List["PoiSource"] = Relationship(back_populates="poi")
    media: List["PoiMedia"] = Relationship(back_populates="poi")
    narrations: List["Narration"] = Relationship(back_populates="poi")

class PoiSource(SQLModel, table=True):
    __tablename__ = "poi_sources"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    poi_id: uuid.UUID = Field(foreign_key="poi.id", index=True)
    name: str 
    url: Optional[str] = None
    poi: Optional[Poi] = Relationship(back_populates="sources")

class PoiMedia(SQLModel, table=True):
    __tablename__ = "poi_media"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    poi_id: uuid.UUID = Field(foreign_key="poi.id", index=True)
    url: str
    media_type: str = "image"
    license_type: str 
    author: str
    source_page_url: str
    poi: Optional[Poi] = Relationship(back_populates="media")

class Narration(SQLModel, table=True):
    __tablename__ = "narrations"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    poi_id: uuid.UUID = Field(foreign_key="poi.id", index=True)
    locale: str = Field(default="ru")
    url: str
    duration_seconds: float = Field(default=0.0)
    voice_id: Optional[str] = None
    filesize_bytes: Optional[int] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    poi: Optional[Poi] = Relationship(back_populates="narrations")

class TourBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    description_ru: Optional[str] = None
    duration_minutes: Optional[int] = None
    published_at: Optional[datetime] = Field(default=None, index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class Tour(TourBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city: Optional[City] = Relationship(back_populates="tours")
    items: List["TourItem"] = Relationship(back_populates="tour")
    sources: List["TourSource"] = Relationship(back_populates="tour")
    media: List["TourMedia"] = Relationship(back_populates="tour")

class TourItem(SQLModel, table=True):
    __tablename__ = "tour_items"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tour_id: uuid.UUID = Field(foreign_key="tour.id", index=True)
    poi_id: Optional[uuid.UUID] = Field(default=None, foreign_key="poi.id")
    order_index: int = Field(default=0)
    tour: Optional[Tour] = Relationship(back_populates="items")
    poi: Optional[Poi] = Relationship(back_populates="tour_items")

class TourSource(SQLModel, table=True):
    __tablename__ = "tour_sources"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tour_id: uuid.UUID = Field(foreign_key="tour.id", index=True)
    name: str
    url: Optional[str] = None
    retrieved_at: datetime = Field(default_factory=datetime.utcnow)
    tour: Optional[Tour] = Relationship(back_populates="sources")

class TourMedia(SQLModel, table=True):
    __tablename__ = "tour_media"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tour_id: uuid.UUID = Field(foreign_key="tour.id", index=True)
    url: str
    media_type: str = "image"
    license_type: str
    author: str
    source_page_url: str
    tour: Optional[Tour] = Relationship(back_populates="media")

class PurchaseIntent(SQLModel, table=True):
    __tablename__ = "purchase_intents"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    tour_id: uuid.UUID = Field(index=True)
    device_anon_id: str = Field(index=True)
    platform: str 
    status: str = Field(default="PENDING", index=True) 
    idempotency_key: str = Field(unique=True, index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Purchase(SQLModel, table=True):
    __tablename__ = "purchases"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    intent_id: uuid.UUID = Field(foreign_key="purchase_intents.id", unique=True)
    store: str 
    store_transaction_id: str = Field(index=True)
    purchased_at: datetime = Field(default_factory=datetime.utcnow)
    status: str = Field(default="VALID") # VALID, REVOKED, ANONYMIZED

class Entitlement(SQLModel, table=True):
    __tablename__ = "entitlements"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    tour_id: uuid.UUID = Field(index=True)
    device_anon_id: str = Field(index=True)
    granted_at: datetime = Field(default_factory=datetime.utcnow)
    revoked_at: Optional[datetime] = None

# --- PR-10: Deletion Requests ---

class DeletionRequest(SQLModel, table=True):
    __tablename__ = "deletion_requests"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    subject_type: str = Field(default="DEVICE") # DEVICE
    subject_id: str = Field(index=True) # device_anon_id
    status: str = Field(default="PENDING", index=True) # PENDING, PROCESSING, COMPLETED, FAILED
    request_channel: str = Field(default="IN_APP") # IN_APP, WEB
    
    idempotency_key: str = Field(unique=True, index=True)
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    
    log_json: Optional[str] = None
    last_error: Optional[str] = None

# --- Helpers ---
class Job(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    type: str
    status: str = Field(default="PENDING", index=True)
    payload: Optional[str] = None
    result: Optional[str] = None
    error: Optional[str] = None
    idempotency_key: Optional[str] = Field(default=None, unique=True, index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class AuditLog(SQLModel, table=True):
    __tablename__ = "audit_logs"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    action: str 
    target_id: uuid.UUID = Field(index=True)
    actor_type: str = "admin_token" # or "system"
    actor_fingerprint: str 
    trace_id: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class IngestionRun(SQLModel, table=True):
    __tablename__ = "ingestion_runs"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    started_at: datetime = Field(default_factory=datetime.utcnow)
    finished_at: Optional[datetime] = None
    status: str = Field(default="RUNNING")
    stats_json: Optional[str] = None
    last_error: Optional[str] = None

class PoiStaging(SQLModel, table=True):
    __tablename__ = "poi_ingestion_staging"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    osm_id: str = Field(index=True)
    raw_payload: str
    name_ru: Optional[str] = None
    normalized_json: Optional[str] = None

class HelperPlace(SQLModel, table=True):
    __tablename__ = "helper_places"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    type: str 
    lat: float = Field(index=True)
    lon: float = Field(index=True)
    geo: Any = Field(sa_column=Column(Geography("POINT", srid=4326, spatial_index=True)), default=None)
    name_ru: Optional[str] = None
    osm_id: Optional[str] = None
