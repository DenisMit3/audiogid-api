"""add_blacklisted_tokens

Revision ID: 72bbaccdaf25
Revises: b31eee07242d
Create Date: 2026-01-30 09:27:21.832266

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '72bbaccdaf25'
down_revision: Union[str, None] = 'b31eee07242d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'blacklisted_tokens',
        sa.Column('token_hash', sa.String(), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('token_hash')
    )
    op.create_index(op.f('ix_blacklisted_tokens_user_id'), 'blacklisted_tokens', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_blacklisted_tokens_user_id'), table_name='blacklisted_tokens')
    op.drop_table('blacklisted_tokens')
