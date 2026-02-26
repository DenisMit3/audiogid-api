"""Add override_lat/override_lon to tour_items

Revision ID: add_tour_item_override_coords
Revises: add_transition_audio
Create Date: 2026-02-25

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_tour_item_override_coords'
down_revision = 'add_transition_audio'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = sa.inspect(conn)
    columns = [c['name'] for c in inspector.get_columns('tour_items')]
    
    if 'override_lat' not in columns:
        op.add_column('tour_items', sa.Column('override_lat', sa.Float(), nullable=True))
    
    if 'override_lon' not in columns:
        op.add_column('tour_items', sa.Column('override_lon', sa.Float(), nullable=True))


def downgrade():
    op.drop_column('tour_items', 'override_lon')
    op.drop_column('tour_items', 'override_lat')
