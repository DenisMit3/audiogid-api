"""0007_pr8_purchases.py

Revision ID: 0007_pr8_purchases
Revises: 0006_pr7_tours
Create Date: 2026-01-24 16:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = '0007_pr8_purchases'
down_revision: Union[str, None] = '0006_pr7_tours'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Purchase Intents
    op.create_table('purchase_intents',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('tour_id', sa.Uuid(), nullable=False),
        sa.Column('device_anon_id', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('platform', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('status', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('idempotency_key', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_purchase_intents_city_slug'), 'purchase_intents', ['city_slug'], unique=False)
    op.create_index(op.f('ix_purchase_intents_device_anon_id'), 'purchase_intents', ['device_anon_id'], unique=False)
    op.create_index(op.f('ix_purchase_intents_idempotency_key'), 'purchase_intents', ['idempotency_key'], unique=True)
    op.create_index(op.f('ix_purchase_intents_status'), 'purchase_intents', ['status'], unique=False)
    op.create_index(op.f('ix_purchase_intents_tour_id'), 'purchase_intents', ['tour_id'], unique=False)

    # 2. Purchases
    op.create_table('purchases',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('intent_id', sa.Uuid(), nullable=False),
        sa.Column('store', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('store_transaction_id', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('purchased_at', sa.DateTime(), nullable=False),
        sa.Column('status', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.ForeignKeyConstraint(['intent_id'], ['purchase_intents.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('intent_id')
    )
    op.create_index(op.f('ix_purchases_store_transaction_id'), 'purchases', ['store_transaction_id'], unique=False)

    # 3. Entitlements
    op.create_table('entitlements',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('city_slug', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('tour_id', sa.Uuid(), nullable=False),
        sa.Column('device_anon_id', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('granted_at', sa.DateTime(), nullable=False),
        sa.Column('revoked_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_entitlements_city_slug'), 'entitlements', ['city_slug'], unique=False)
    op.create_index(op.f('ix_entitlements_device_anon_id'), 'entitlements', ['device_anon_id'], unique=False)
    op.create_index(op.f('ix_entitlements_tour_id'), 'entitlements', ['tour_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_entitlements_tour_id'), table_name='entitlements')
    op.drop_index(op.f('ix_entitlements_device_anon_id'), table_name='entitlements')
    op.drop_index(op.f('ix_entitlements_city_slug'), table_name='entitlements')
    op.drop_table('entitlements')
    
    op.drop_index(op.f('ix_purchases_store_transaction_id'), table_name='purchases')
    op.drop_table('purchases')
    
    op.drop_index(op.f('ix_purchase_intents_tour_id'), table_name='purchase_intents')
    op.drop_index(op.f('ix_purchase_intents_status'), table_name='purchase_intents')
    op.drop_index(op.f('ix_purchase_intents_idempotency_key'), table_name='purchase_intents')
    op.drop_index(op.f('ix_purchase_intents_device_anon_id'), table_name='purchase_intents')
    op.drop_index(op.f('ix_purchase_intents_city_slug'), table_name='purchase_intents')
    op.drop_table('purchase_intents')
