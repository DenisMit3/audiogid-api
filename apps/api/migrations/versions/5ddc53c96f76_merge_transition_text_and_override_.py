"""merge_transition_text_and_override_coords

Revision ID: 5ddc53c96f76
Revises: add_transition_text_en, merge_override_coords
Create Date: 2026-02-27 09:53:17.317667

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '5ddc53c96f76'
down_revision: Union[str, None] = ('add_transition_text_en', 'merge_override_coords')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
