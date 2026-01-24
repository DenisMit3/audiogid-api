"""0003_pr2_ingestion

Revision ID: 0003_pr2_ingestion
Revises: 0002_pr1_schema
Create Date: 2026-01-24 13:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '0003_pr2_ingestion'
down_revision: Union[str, None] = '0002_pr1_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Ingestion Runs
    op.create_table('ingestion_runs',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('started_at', sa.DateTime(), nullable=False),
        sa.Column('finished_at', sa.DateTime(), nullable=True),
        sa.Column('status', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('stats_json', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('last_error', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_ingestion_runs_city_slug'), 'ingestion_runs', ['city_slug'], unique=False)
    
    # 2. Poi Staging
    op.create_table('poi_ingestion_staging',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('osm_id', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('raw_payload', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('name_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('normalized_json', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_poi_ingestion_staging_city_slug'), 'poi_ingestion_staging', ['city_slug'], unique=False)
    op.create_index(op.f('ix_poi_ingestion_staging_osm_id'), 'poi_ingestion_staging', ['osm_id'], unique=False)
    
    # 3. Helper Places
    op.create_table('helper_places',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('lat', sa.Float(), nullable=False),
        sa.Column('lon', sa.Float(), nullable=False),
        sa.Column('name_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('osm_id', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_helper_places_city_slug'), 'helper_places', ['city_slug'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_helper_places_city_slug'), table_name='helper_places')
    op.drop_table('helper_places')
    op.drop_index(op.f('ix_poi_ingestion_staging_osm_id'), table_name='poi_ingestion_staging')
    op.drop_index(op.f('ix_poi_ingestion_staging_city_slug'), table_name='poi_ingestion_staging')
    op.drop_table('poi_ingestion_staging')
    op.drop_index(op.f('ix_ingestion_runs_city_slug'), table_name='ingestion_runs')
    op.drop_table('ingestion_runs')
