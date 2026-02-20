"""add narration transcript column

Revision ID: add_narration_transcript
Revises: add_missing_poi_fields_final
Create Date: 2026-02-20
"""
from alembic import op
import sqlalchemy as sa

revision = 'add_narration_transcript'
down_revision = 'add_missing_poi_fields_final'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('narrations', sa.Column('transcript', sa.Text(), nullable=True))

def downgrade():
    op.drop_column('narrations', 'transcript')
