"""merge_all_heads_feb2026

Revision ID: 81c0eddbeed8
Revises: add_app_settings, add_narration_transcript, add_transition_audio
Create Date: 2026-02-25 08:12:54.408080

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '81c0eddbeed8'
down_revision: Union[str, None] = ('add_app_settings', 'add_narration_transcript', 'add_transition_audio')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
