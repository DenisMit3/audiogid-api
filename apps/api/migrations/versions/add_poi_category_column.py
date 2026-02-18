"""add poi category column

Revision ID: add_poi_category_column
Revises: 72bbaccdaf25
Create Date: 2026-01-31 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_poi_category_column'
down_revision = '72bbaccdaf25'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('poi', sa.Column('category', sa.String(), nullable=False, server_default='landmark'))
    op.create_index(op.f('ix_poi_category'), 'poi', ['category'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_poi_category'), table_name='poi')
    op.drop_column('poi', 'category')
