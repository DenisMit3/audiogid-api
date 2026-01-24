from typing import Optional, List
from sqlmodel import Field, SQLModel, Relationship
from datetime import datetime
import uuid

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

# --- Public Content Models ---

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
    # sources and media to be added in Phase 3
