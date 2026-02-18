"""add missing poi fields final

Revision ID: add_missing_poi_fields_final
Revises: fix_audit_logs_and_merge
Create Date: 2026-01-31 14:20:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

# revision identifiers, used by Alembic.
revision: str = 'add_missing_poi_fields_final'
down_revision: Union[str, None] = 'fix_audit_logs_and_merge'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add title_en if not exists (we assume it doesn't based on 500 error)
    op.add_column('poi', sa.Column('title_en', sa.String(), nullable=True))
    op.add_column('poi', sa.Column('description_en', sa.String(), nullable=True))
    op.add_column('poi', sa.Column('address', sa.String(), nullable=True))
    op.add_column('poi', sa.Column('cover_image', sa.String(), nullable=True))
    op.add_column('poi', sa.Column('opening_hours', sa.JSON(), nullable=True))
    op.add_column('poi', sa.Column('external_links', sa.JSON(), nullable=True))


def downgrade() -> None:
    op.drop_column('poi', 'external_links')
    op.drop_column('poi', 'opening_hours')
    op.drop_column('poi', 'cover_image')
    op.drop_column('poi', 'address')
    op.drop_column('poi', 'description_en')
    op.drop_column('poi', 'title_en')
