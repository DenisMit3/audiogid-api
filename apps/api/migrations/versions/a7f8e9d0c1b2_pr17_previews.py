"""pr17_preview_fields

Revision ID: a7f8e9d0c1b2
Revises: f3b4c5d6e7f8
Create Date: 2026-01-25 21:05:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = 'a7f8e9d0c1b2'
down_revision: Union[str, None] = 'f3b4c5d6e7f8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('poi', sa.Column('preview_audio_url', sqlmodel.sql.sqltypes.AutoString(), nullable=True))
    op.add_column('poi', sa.Column('preview_bullets', sa.JSON(), nullable=True))


def downgrade() -> None:
    op.drop_column('poi', 'preview_bullets')
    op.drop_column('poi', 'preview_audio_url')
