"""merge_pr15_16_17

Revision ID: 32c34c8cc1e6
Revises: a309fae5ecd9, a7f8e9d0c1b2
Create Date: 2026-01-25 21:17:59.085571

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '32c34c8cc1e6'
down_revision: Union[str, None] = ('a309fae5ecd9', 'a7f8e9d0c1b2')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
