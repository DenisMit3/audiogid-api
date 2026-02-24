"""Add transition_audio_url to tour_items

Revision ID: add_transition_audio
Revises: merge_heads_2026
Create Date: 2026-02-24

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_transition_audio'
down_revision = 'merge_heads_2026'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('tour_items', sa.Column('transition_audio_url', sa.String(), nullable=True))


def downgrade():
    op.drop_column('tour_items', 'transition_audio_url')
