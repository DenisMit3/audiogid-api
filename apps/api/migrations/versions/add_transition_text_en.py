"""add transition_text_en to tour_items

Revision ID: add_transition_text_en
Revises: 81c0eddbeed8
Create Date: 2026-02-27

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_transition_text_en'
down_revision = '81c0eddbeed8'
branch_labels = None
depends_on = None


def upgrade():
    # Add transition_text_en column to tour_items table
    op.add_column('tour_items', sa.Column('transition_text_en', sa.String(), nullable=True))


def downgrade():
    op.drop_column('tour_items', 'transition_text_en')
