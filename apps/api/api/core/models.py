from typing import Optional, List, Any
from sqlmodel import Field, SQLModel, Relationship
from sqlalchemy import Column
import sqlalchemy as sa
from geoalchemy2 import Geography
from datetime import datetime
import uuid

# --- Previous Models ---
class CityBase(SQLModel):
    slug: str = Field(index=True, unique=True)
    name_ru: str
    name_en: Optional[str] = None
    description_ru: Optional[str] = None
    description_en: Optional[str] = None
    cover_image: Optional[str] = None
    
    # Map configuration
    bounds_lat_min: Optional[float] = None
    bounds_lat_max: Optional[float] = None
    bounds_lon_min: Optional[float] = None
    bounds_lon_max: Optional[float] = None
    default_zoom: Optional[float] = None
    timezone: Optional[str] = None
    
    is_active: bool = Field(default=True)
    osm_relation_id: Optional[int] = Field(default=None)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class City(CityBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tours: List["Tour"] = Relationship(back_populates="city")
    pois: List["Poi"] = Relationship(back_populates="city")

class PoiBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    description_ru: Optional[str] = None
    title_en: Optional[str] = None
    description_en: Optional[str] = None
    category: str = Field(default="landmark", index=True)
    address: Optional[str] = None
    cover_image: Optional[str] = None
    
    opening_hours: Optional[Any] = Field(default=None, sa_column=Column(sa.JSON))
    external_links: Optional[List[str]] = Field(default=None, sa_column=Column(sa.JSON))
    
    published_at: Optional[datetime] = Field(default=None, index=True)
    lat: Optional[float] = Field(default=None)
    lon: Optional[float] = Field(default=None)
    osm_id: Optional[str] = Field(default=None, index=True)
    wikidata_id: Optional[str] = Field(default=None, index=True)
    confidence_score: float = Field(default=0.0)
    preview_audio_url: Optional[str] = None
    preview_bullets: Optional[List[str]] = Field(default=None, sa_column=Column(sa.JSON))
    updated_at: datetime = Field(default_factory=datetime.utcnow, index=True)

class Poi(PoiBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    geo: Any = Field(sa_column=Column(Geography("POINT", srid=4326, spatial_index=True)), default=None)
    city: Optional[City] = Relationship(back_populates="pois")
    tour_items: List["TourItem"] = Relationship(back_populates="poi")
    sources: List["PoiSource"] = Relationship(back_populates="poi")
    media: List["PoiMedia"] = Relationship(back_populates="poi")
    narrations: List["Narration"] = Relationship(back_populates="poi")
    
    # Soft Delete
    is_deleted: bool = Field(default=False, index=True)
    deleted_at: Optional[datetime] = None

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
    kids_url: Optional[str] = None # Kids-friendly version
    duration_seconds: float = Field(default=0.0)
    transcript: Optional[str] = None
    voice_id: Optional[str] = None
    filesize_bytes: Optional[int] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    poi: Optional[Poi] = Relationship(back_populates="narrations")

class TourBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    description_ru: Optional[str] = None
    title_en: Optional[str] = None
    description_en: Optional[str] = None
    cover_image: Optional[str] = None
    
    tour_type: str = Field(default="walking") # walking, driving, cycling, boat
    difficulty: str = Field(default="easy") # easy, moderate, hard
    distance_km: Optional[float] = None
    
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
    
    # Soft Delete
    is_deleted: bool = Field(default=False, index=True)
    deleted_at: Optional[datetime] = None

class TourItem(SQLModel, table=True):
    __tablename__ = "tour_items"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tour_id: uuid.UUID = Field(foreign_key="tour.id", index=True)
    poi_id: Optional[uuid.UUID] = Field(default=None, foreign_key="poi.id")
    order_index: int = Field(default=0)
    transition_text_ru: Optional[str] = None
    duration_seconds: Optional[int] = None # Recommended stay time
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
    slug: str = Field(unique=True, index=True) # e.g. "kaliningrad_city_access"
    scope: str = "city" # city, tour
    ref: str # slug города или UUID тура
    title_ru: str
    price_amount: float = 0.0
    price_currency: str = "RUB"
    is_active: bool = Field(default=True)

class EntitlementGrant(SQLModel, table=True):
    __tablename__ = "entitlement_grants"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    device_anon_id: str = Field(index=True)
    user_id: Optional[uuid.UUID] = Field(default=None, index=True)
    entitlement_id: uuid.UUID = Field(foreign_key="entitlements.id", index=True)
    source: str = "yookassa" # yookassa, store, system, promo
    source_ref: str = Field(unique=True, index=True) # e.g. payment_id или transaction_id
    granted_at: datetime = Field(default_factory=datetime.utcnow)
    revoked_at: Optional[datetime] = None
    
    entitlement: Optional[Entitlement] = Relationship()

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
    progress: int = Field(default=0)
    payload: Optional[str] = None
    result: Optional[str] = None
    error: Optional[str] = None
    idempotency_key: Optional[str] = Field(default=None, unique=True, index=True)
    trace_id: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    created_by: Optional[uuid.UUID] = None

class AuditLog(SQLModel, table=True):
    __tablename__ = "audit_logs"
    __table_args__ = (
        sa.Index("ix_audit_logs_target_ts", "target_id", sa.text("timestamp DESC")),
    )
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    action: str 
    target_id: uuid.UUID = Field(index=True)
    actor_type: str = "admin_token" # or "system"
    actor_fingerprint: str 
    trace_id: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    # Phase 10 extensions
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    diff_json: Optional[str] = None # JSON string of changes

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

# --- Auth Models (PR-58) ---
class User(SQLModel, table=True):
    __tablename__ = "users"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    role: str = Field(default="user") # user, admin, editor
    created_at: datetime = Field(default_factory=datetime.utcnow)
    is_active: bool = Field(default=True)
    
    role_id: Optional[uuid.UUID] = Field(default=None, foreign_key="roles.id")
    
    # Relationships
    assigned_role: Optional["Role"] = Relationship(back_populates="users")
    identities: List["UserIdentity"] = Relationship(back_populates="user")
    
    # Email Auth
    email: Optional[str] = Field(default=None, index=True, sa_column_kwargs={"unique": True})
    hashed_password: Optional[str] = None
    
class UserIdentity(SQLModel, table=True):
    __tablename__ = "user_identities"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id", index=True)
    provider: str = Field(index=True) # phone, telegram
    provider_id: str = Field(index=True) # +7999..., 12345678 (tg_id)
    last_login: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    user: Optional[User] = Relationship(back_populates="identities")

class OtpCode(SQLModel, table=True):
    __tablename__ = "otp_codes"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    phone: str = Field(index=True)
    code: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    expires_at: datetime
    attempts: int = 0
    used: bool = False

class BlacklistedToken(SQLModel, table=True):
    __tablename__ = "blacklisted_tokens"
    token_hash: str = Field(primary_key=True)
    expires_at: datetime
    user_id: Optional[uuid.UUID] = Field(default=None, index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

# --- Content Versions (Phase 3) ---
class PoiVersion(SQLModel, table=True):
    __tablename__ = "poi_versions"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    poi_id: uuid.UUID = Field(foreign_key="poi.id", index=True) 
    version_at: datetime = Field(default_factory=datetime.utcnow)
    changed_by: Optional[uuid.UUID] = Field(default=None) # User ID
    
    # Snapshot of important fields
    title_ru: str 
    description_ru: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    full_snapshot_json: Optional[str] = None # schema-less backup

class TourVersion(SQLModel, table=True):
    __tablename__ = "tour_versions"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tour_id: uuid.UUID = Field(foreign_key="tour.id", index=True)
    version_at: datetime = Field(default_factory=datetime.utcnow)
    changed_by: Optional[uuid.UUID] = Field(default=None)
    
    title_ru: str
    description_ru: Optional[str] = None
    full_snapshot_json: Optional[str] = None

class ContentValidationIssue(SQLModel, table=True):
    __tablename__ = "content_validation_issues"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    entity_type: str = Field(index=True) # "poi" or "tour"
    entity_id: uuid.UUID = Field(index=True)
    issue_type: str # "missing_source", "missing_audio", "unpublished_poi"
    severity: str # "blocker", "warning"
    message: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    fixed_at: Optional[datetime] = None

class Permission(SQLModel, table=True):
    __tablename__ = "permissions"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    slug: str = Field(unique=True, index=True) # e.g. 'poi:read'
    description: Optional[str] = None
    
    role_permissions: List["RolePermission"] = Relationship(back_populates="permission")

class Role(SQLModel, table=True):
    __tablename__ = "roles"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    slug: str = Field(unique=True, index=True) # e.g. 'admin'
    name: str
    description: Optional[str] = None
    
    users: List["User"] = Relationship(back_populates="assigned_role")
    role_permissions: List["RolePermission"] = Relationship(back_populates="role")

class RolePermission(SQLModel, table=True):
    __tablename__ = "role_permissions"
    role_id: uuid.UUID = Field(foreign_key="roles.id", primary_key=True)
    permission_id: uuid.UUID = Field(foreign_key="permissions.id", primary_key=True)
    
    role: "Role" = Relationship(back_populates="role_permissions")
    permission: "Permission" = Relationship(back_populates="role_permissions")

# --- Analytics (Phase 5) ---

class AppEvent(SQLModel, table=True):
    __tablename__ = "app_events"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    ts: datetime = Field(default_factory=datetime.utcnow, index=True) # Sorted time
    event_type: str = Field(index=True) # e.g. "app_open", "screen_view"
    user_id: Optional[uuid.UUID] = Field(default=None, index=True)
    anon_id: Optional[str] = Field(default=None, index=True)
    payload_json: Optional[str] = None # JSONB

class ContentEvent(SQLModel, table=True):
    # Specialized event table for Content interactions to keep main table smaller?
    # Or just use AppEvent? User requested "AppEvent, ContentEvent, PurchaseEvent (separate)".
    __tablename__ = "content_events"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    ts: datetime = Field(default_factory=datetime.utcnow, index=True)
    event_type: str = Field(index=True) # "poi_viewed", "tour_started"
    user_id: Optional[uuid.UUID] = Field(default=None)
    anon_id: Optional[str] = Field(default=None)
    entity_type: str # "poi", "tour"
    entity_id: uuid.UUID = Field(index=True)
    duration_seconds: Optional[int] = None # For viewed/listened

class PurchaseEvent(SQLModel, table=True):
    __tablename__ = "purchase_events"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    ts: datetime = Field(default_factory=datetime.utcnow, index=True)
    user_id: Optional[uuid.UUID] = Field(default=None, index=True)
    anon_id: Optional[str] = Field(default=None)
    amount: float
    currency: str
    product_id: str
    store: str # apple, google

class AnalyticsDailyStats(SQLModel, table=True):
    __tablename__ = "analytics_daily_stats"
    date: datetime = Field(primary_key=True) # Midnight UTC
    dau: int = 0
    mau: int = 0 # Rolling 30d calculated on this day
    new_users: int = 0
    total_revenue: float = 0.0
    sessions_count: int = 0
    
class UserCohort(SQLModel, table=True):
    __tablename__ = "user_cohorts"
    user_id: uuid.UUID = Field(primary_key=True)
    cohort_date: datetime = Field(index=True) # First seen date (midnight)
    source: Optional[str] = None # install source

class RetentionMatrix(SQLModel, table=True):
    __tablename__ = "retention_matrix"
    cohort_date: datetime = Field(primary_key=True)
    day_n: int = Field(primary_key=True) # 0, 1, 7, 30...
    retained_count: int = 0
    percentage: float = 0.0


class Funnel(SQLModel, table=True):
    __tablename__ = "funnels"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    name: str
    owner_id: Optional[uuid.UUID] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    steps: List["FunnelStep"] = Relationship(back_populates="funnel")

class FunnelStep(SQLModel, table=True):
    __tablename__ = "funnel_steps"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    funnel_id: uuid.UUID = Field(foreign_key="funnels.id", index=True)
    order_index: int
    event_type: str 
    step_name: Optional[str] = None
    
    funnel: Optional[Funnel] = Relationship(back_populates="steps")

class FunnelConversion(SQLModel, table=True):
    __tablename__ = "funnel_conversions"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    date: datetime = Field(index=True)
    funnel_id: uuid.UUID = Field(foreign_key="funnels.id", index=True) # Logical link, maybe cascade delete manually
    step_order: int

    users_count: int = 0

class QRMapping(SQLModel, table=True):
    __tablename__ = "qr_mappings"
    
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    code: str = Field(unique=True, index=True)  # "SPB001"
    target_type: str  # "poi", "tour", "city"
    target_id: uuid.UUID = Field(index=True)
    label: Optional[str] = None 
    is_active: bool = Field(default=True)
    scans_count: int = Field(default=0)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_scanned_at: Optional[datetime] = None

class UserPushToken(SQLModel, table=True):
    __tablename__ = "user_push_tokens"
    token: str = Field(primary_key=True)
    user_id: Optional[uuid.UUID] = Field(default=None, index=True)
    device_id: str = Field(index=True)
    platform: str = Field(default="unknown") # android, ios
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class AppSettings(SQLModel, table=True):
    __tablename__ = "app_settings"
    key: str = Field(primary_key=True)
    value: str = Field(default="")
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    updated_by: Optional[uuid.UUID] = Field(default=None)


# --- Itineraries (User Created) ---

class Itinerary(SQLModel, table=True):
    __tablename__ = "itineraries"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: Optional[uuid.UUID] = Field(default=None, index=True) 
    device_anon_id: Optional[str] = Field(default=None, index=True)
    
    title: str = "My Trip"
    city_slug: str = Field(index=True)
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    items: List["ItineraryItem"] = Relationship(back_populates="itinerary", sa_relationship_kwargs={"cascade": "all, delete"})

class ItineraryItem(SQLModel, table=True):
    __tablename__ = "itinerary_items"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    itinerary_id: uuid.UUID = Field(foreign_key="itineraries.id", index=True)
    poi_id: uuid.UUID = Field(foreign_key="poi.id", index=True)
    
    order_index: int
    
    itinerary: Optional[Itinerary] = Relationship(back_populates="items")
    poi: Optional[Poi] = Relationship()
