"""0006_pr7_tours.py

Revision ID: 0006_pr7_tours
Revises: 0005_pr6_nearby
Create Date: 2026-01-24 15:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = '0006_pr7_tours'
down_revision: Union[str, None] = '0005_pr6_nearby'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Upgrade Tour Table
    # Existing: id, city_slug, title_ru, is_published
    # New: description_ru, duration_minutes, published_at, created_at, updated_at
    op.add_column('tour', sa.Column('description_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=True))
    op.add_column('tour', sa.Column('duration_minutes', sa.Integer(), nullable=True))
    op.add_column('tour', sa.Column('published_at', sa.DateTime(), nullable=True))
    op.add_column('tour', sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.func.now()))
    op.add_column('tour', sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()))
    
    op.create_index(op.f('ix_tour_published_at'), 'tour', ['published_at'], unique=False)
    
    # Drop old is_published
    with op.batch_alter_table('tour') as batch_op:
        batch_op.drop_column('is_published')

    # 2. Tour Sources
    op.create_table('tour_sources',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('tour_id', sa.Uuid(), nullable=False),
        sa.Column('name', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('url', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('retrieved_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['tour_id'], ['tour.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_tour_sources_tour_id'), 'tour_sources', ['tour_id'], unique=False)

    # 3. Tour Media
    op.create_table('tour_media',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('tour_id', sa.Uuid(), nullable=False),
        sa.Column('url', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('media_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('license_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('author', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('source_page_url', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.ForeignKeyConstraint(['tour_id'], ['tour.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_tour_media_tour_id'), 'tour_media', ['tour_id'], unique=False)
    
    # 4. Tour Items
    op.create_table('tour_items',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('tour_id', sa.Uuid(), nullable=False),
        sa.Column('poi_id', sa.Uuid(), nullable=True),
        sa.Column('order_index', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['poi_id'], ['poi.id'], ),
        sa.ForeignKeyConstraint(['tour_id'], ['tour.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_tour_items_tour_id'), 'tour_items', ['tour_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_tour_items_tour_id'), table_name='tour_items')
    op.drop_table('tour_items')
    op.drop_index(op.f('ix_tour_media_tour_id'), table_name='tour_media')
    op.drop_table('tour_media')
    op.drop_index(op.f('ix_tour_sources_tour_id'), table_name='tour_sources')
    op.drop_table('tour_sources')
    
    with op.batch_alter_table('tour') as batch_op:
        batch_op.add_column(sa.Column('is_published', sa.Boolean(), nullable=False, server_default=sa.text('false')))
        batch_op.drop_index(op.f('ix_tour_published_at'))
        batch_op.drop_column('updated_at')
        batch_op.drop_column('created_at')
        batch_op.drop_column('published_at')
        batch_op.drop_column('duration_minutes')
        batch_op.drop_column('description_ru')
