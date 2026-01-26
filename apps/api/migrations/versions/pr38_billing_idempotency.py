"""pr38_billing_idempotency

Revision ID: pr38_billing_idempotency
Revises: 11b010928b29
Create Date: 2026-01-26 22:20:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = 'pr38_billing_idempotency'
down_revision: Union[str, None] = '11b010928b29'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drop old unique constraint on source_ref only (if exists)
    # Note: SQLModel creates it as ix_entitlement_grants_source_ref
    op.drop_index('ix_entitlement_grants_source_ref', table_name='entitlement_grants', if_exists=True)
    
    # Add composite unique constraint for idempotency: (source, source_ref)
    # This ensures Apple tx123 and Google tx123 don't conflict
    op.create_index(
        'uq_entitlement_grants_source_source_ref',
        'entitlement_grants',
        ['source', 'source_ref'],
        unique=True
    )
    
    # Also keep a non-unique index on source_ref for fast lookups
    op.create_index(
        'ix_entitlement_grants_source_ref_lookup',
        'entitlement_grants',
        ['source_ref'],
        unique=False
    )


def downgrade() -> None:
    op.drop_index('ix_entitlement_grants_source_ref_lookup', table_name='entitlement_grants')
    op.drop_index('uq_entitlement_grants_source_source_ref', table_name='entitlement_grants')
    # Recreate old unique index
    op.create_index('ix_entitlement_grants_source_ref', 'entitlement_grants', ['source_ref'], unique=True)
