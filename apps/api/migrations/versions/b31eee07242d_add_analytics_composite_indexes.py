"""add_analytics_composite_indexes

Revision ID: b31eee07242d
Revises: 52efc9dc259e
Create Date: 2026-01-28 20:22:13.627086

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = 'b31eee07242d'
down_revision: Union[str, None] = '52efc9dc259e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
