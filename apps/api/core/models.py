from typing import Optional, List
from sqlmodel import Field, SQLModel, Relationship
from datetime import datetime
import uuid
# ... Imports from previous PRs maintained generally, but re-stating for file overwrite ...

# --- Job (Existing) ---
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

# --- Public Content Models (Existing) ---
class CityBase(SQLModel):
    slug: str = Field(index=True, unique=True)
    name_ru: str
    is_active: bool = Field(default=True)

class City(CityBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    tours: List["Tour"] = Relationship(back_populates="city")
    pois: List["Poi"] = Relationship(back_populates="city")

class TourBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    is_published: bool = Field(default=False)

class Tour(TourBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city: Optional[City] = Relationship(back_populates="tours")

class PoiBase(SQLModel):
    title_ru: str
    city_slug: str = Field(index=True, foreign_key="city.slug")
    is_published: bool = Field(default=False)

class Poi(PoiBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city: Optional[City] = Relationship(back_populates="pois")

# --- PR-2 Ingestion Models ---

class IngestionRun(SQLModel, table=True):
    __tablename__ = "ingestion_runs"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    started_at: datetime = Field(default_factory=datetime.utcnow)
    finished_at: Optional[datetime] = None
    status: str = Field(default="RUNNING") # RUNNING, COMPLETED, FAILED
    stats_json: Optional[str] = None
    last_error: Optional[str] = None

class PoiStaging(SQLModel, table=True):
    __tablename__ = "poi_ingestion_staging"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    osm_id: str = Field(index=True)
    raw_payload: str # JSON
    name_ru: Optional[str] = None
    normalized_json: Optional[str] = None

class HelperPlace(SQLModel, table=True):
    __tablename__ = "helper_places"
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    city_slug: str = Field(index=True)
    type: str # toilet, water, cafe
    lat: float
    lon: float
    name_ru: Optional[str] = None
    osm_id: Optional[str] = None
