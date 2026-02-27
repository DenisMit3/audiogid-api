"""add helper_place fields

Revision ID: add_helper_place_fields
Revises: 5ddc53c96f76
Create Date: 2026-02-27

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_helper_place_fields'
down_revision = '5ddc53c96f76'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('helper_places', sa.Column('name_en', sa.String(), nullable=True))
    op.add_column('helper_places', sa.Column('address', sa.String(), nullable=True))
    op.add_column('helper_places', sa.Column('opening_hours', sa.String(), nullable=True))


def downgrade():
    op.drop_column('helper_places', 'opening_hours')
    op.drop_column('helper_places', 'address')
    op.drop_column('helper_places', 'name_en')
