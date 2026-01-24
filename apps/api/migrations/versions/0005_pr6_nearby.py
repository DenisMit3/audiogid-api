"""0005_pr6_nearby.py

Revision ID: 0005_pr6_nearby
Revises: 0004_pr5_gates
Create Date: 2026-01-24 15:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel
from geoalchemy2 import Geography

revision: str = '0005_pr6_nearby'
down_revision: Union[str, None] = '0004_pr5_gates'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Enable PostGIS
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
    
    # 2. Update POI table (Lat/Lon + Geo)
    op.add_column('poi', sa.Column('lat', sa.Float(), nullable=True))
    op.add_column('poi', sa.Column('lon', sa.Float(), nullable=True))
    
    # Use Geography type (Point, 4326) for native meter support
    op.execute("ALTER TABLE poi ADD COLUMN geo geography(Point, 4326);")
    op.execute("CREATE INDEX idx_poi_geo ON poi USING GIST (geo);")

    # 3. Helper Places
    op.create_index(op.f('ix_helper_places_lat'), 'helper_places', ['lat'], unique=False)
    op.create_index(op.f('ix_helper_places_lon'), 'helper_places', ['lon'], unique=False)
    
    op.execute("ALTER TABLE helper_places ADD COLUMN geo geography(Point, 4326);")
    op.execute("CREATE INDEX idx_helper_places_geo ON helper_places USING GIST (geo);")

    # 4. Backfill (Casting geometry->geography is implicit or explicit)
    # Note: ST_MakePoint creates geometry. We cast to geography.
    op.execute("UPDATE poi SET geo = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography WHERE lat IS NOT NULL AND lon IS NOT NULL;")
    op.execute("UPDATE helper_places SET geo = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography WHERE lat IS NOT NULL AND lon IS NOT NULL;")


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS idx_helper_places_geo;")
    op.drop_column('helper_places', 'geo')
    op.drop_index(op.f('ix_helper_places_lon'), table_name='helper_places')
    op.drop_index(op.f('ix_helper_places_lat'), table_name='helper_places')
    
    op.execute("DROP INDEX IF EXISTS idx_poi_geo;")
    op.drop_column('poi', 'geo')
    op.drop_column('poi', 'lon')
    op.drop_column('poi', 'lat')
    
    # Do not drop extension
