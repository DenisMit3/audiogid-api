"""add missing indexes for optimization

Revision ID: 2026_optimize_indexes
Revises: previous_revision
Create Date: 2026-01-30 14:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '2026_optimize_indexes'
down_revision = '72bbaccdaf25'
branch_labels = None
depends_on = None

def upgrade():
    # POI Indexes
    op.create_index(op.f('ix_poi_city_slug_published'), 'poi', ['city_slug', 'published_at'], unique=False)
    op.create_index(op.f('ix_poi_category'), 'poi', ['category'], unique=False)
    
    # Tour Indexes
    op.create_index(op.f('ix_tour_city_slug_published'), 'tour', ['city_slug', 'published_at'], unique=False)
    
    # Tour Items
    op.create_index(op.f('ix_tour_item_tour_id'), 'tour_item', ['tour_id'], unique=False)
    
    # Job Indexes
    op.create_index(op.f('ix_job_status_type'), 'job', ['status', 'type'], unique=False)
    
    # Entitlement
    op.create_index(op.f('ix_entitlement_user_id'), 'entitlement', ['user_id'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_entitlement_user_id'), table_name='entitlement')
    op.drop_index(op.f('ix_job_status_type'), table_name='job')
    op.drop_index(op.f('ix_tour_item_tour_id'), table_name='tour_item')
    op.drop_index(op.f('ix_tour_city_slug_published'), table_name='tour')
    op.drop_index(op.f('ix_poi_category'), table_name='poi')
    op.drop_index(op.f('ix_poi_city_slug_published'), table_name='poi')
