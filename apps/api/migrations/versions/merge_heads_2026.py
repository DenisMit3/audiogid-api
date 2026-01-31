"""merge_heads_2026

Revision ID: merge_heads_2026
Revises: pr59_email_auth, a983726194c6
Create Date: 2026-01-31 10:50:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

# revision identifiers, used by Alembic.
revision: str = 'merge_heads_2026'
down_revision: Union[str, None] = ('pr59_email_auth', 'a983726194c6')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
