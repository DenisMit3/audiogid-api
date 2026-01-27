"""pr58_auth_foundation

Revision ID: pr58_auth_foundation
Revises: pr38_billing_idempotency
Create Date: 2026-01-27 20:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = 'pr58_auth_foundation'
down_revision: Union[str, None] = 'pr38_billing_idempotency'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Users
    op.create_table('users',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('role', sa.String(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    
    # User Identities
    op.create_table('user_identities',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('user_id', sa.Uuid(), nullable=False),
        sa.Column('provider', sa.String(), nullable=False),
        sa.Column('provider_id', sa.String(), nullable=False),
        sa.Column('last_login', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], )
    )
    op.create_index(op.f('ix_user_identities_user_id'), 'user_identities', ['user_id'], unique=False)
    op.create_index(op.f('ix_user_identities_provider'), 'user_identities', ['provider'], unique=False)
    op.create_index(op.f('ix_user_identities_provider_id'), 'user_identities', ['provider_id'], unique=False)

    # Otp Codes
    op.create_table('otp_codes',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('phone', sa.String(), nullable=False),
        sa.Column('code', sa.String(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('attempts', sa.Integer(), nullable=False),
        sa.Column('used', sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_otp_codes_phone'), 'otp_codes', ['phone'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_otp_codes_phone'), table_name='otp_codes')
    op.drop_table('otp_codes')
    op.drop_index(op.f('ix_user_identities_provider_id'), table_name='user_identities')
    op.drop_index(op.f('ix_user_identities_provider'), table_name='user_identities')
    op.drop_index(op.f('ix_user_identities_user_id'), table_name='user_identities')
    op.drop_table('user_identities')
    op.drop_table('users')
