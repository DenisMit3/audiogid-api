"""0002_pr1_schema

Revision ID: 0002_pr1_schema
Revises: 0001_initial
Create Date: 2026-01-24 12:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel
from sqlalchemy.sql import table, column
import uuid

# revision identifiers, used by Alembic.
revision: str = '0002_pr1_schema'
down_revision: Union[str, None] = '0001_initial'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create Tables
    op.create_table('city',
        sa.Column('slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('name_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_city_slug'), 'city', ['slug'], unique=True)
    
    op.create_table('tour',
        sa.Column('title_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('is_published', sa.Boolean(), nullable=False),
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(['city_slug'], ['city.slug'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_tour_city_slug'), 'tour', ['city_slug'], unique=False)
    
    op.create_table('poi',
        sa.Column('title_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('is_published', sa.Boolean(), nullable=False),
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(['city_slug'], ['city.slug'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_poi_city_slug'), 'poi', ['city_slug'], unique=False)

    # 2. Seed Data (Mandatory Day 1 Tenants)
    current_time = '2026-01-01 00:00:00'
    cities_table = table('city',
        column('id', sa.Uuid),
        column('slug', sa.String),
        column('name_ru', sa.String),
        column('is_active', sa.Boolean)
    )
    
    op.bulk_insert(cities_table, [
        {
            'id': uuid.uuid4(),
            'slug': 'kaliningrad_city',
            'name_ru': 'Калининград (Город)',
            'is_active': True
        },
        {
            'id': uuid.uuid4(),
            'slug': 'kaliningrad_oblast',
            'name_ru': 'Калининградская область',
            'is_active': True
        }
    ])


def downgrade() -> None:
    # Allow rollback if needed (beware data loss)
    op.drop_index(op.f('ix_poi_city_slug'), table_name='poi')
    op.drop_table('poi')
    op.drop_index(op.f('ix_tour_city_slug'), table_name='tour')
    op.drop_table('tour')
    op.drop_index(op.f('ix_city_slug'), table_name='city')
    op.drop_table('city')
