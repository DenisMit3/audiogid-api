"""Merge heads: app_settings and override_coords

Revision ID: merge_override_coords
Revises: 81c0eddbeed8, add_tour_item_override_coords
Create Date: 2026-02-26

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'merge_override_coords'
down_revision = ('81c0eddbeed8', 'add_tour_item_override_coords')
branch_labels = None
depends_on = None


def upgrade():
    pass


def downgrade():
    pass
