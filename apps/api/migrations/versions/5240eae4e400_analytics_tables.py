"""analytics_tables

Revision ID: 5240eae4e400
Revises: fc50eae4e300
Create Date: 2026-01-28 12:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = '5240eae4e400'
down_revision: Union[str, None] = 'fc50eae4e300'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # App Events
    op.create_table('app_events',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('ts', sa.DateTime(), nullable=False),
        sa.Column('event_type', sa.String(), nullable=False),
        sa.Column('user_id', sa.Uuid(), nullable=True),
        sa.Column('anon_id', sa.String(), nullable=True),
        sa.Column('payload_json', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_app_events_ts'), 'app_events', ['ts'], unique=False)
    op.create_index(op.f('ix_app_events_event_type'), 'app_events', ['event_type'], unique=False)
    op.create_index(op.f('ix_app_events_user_id'), 'app_events', ['user_id'], unique=False)
    op.create_index(op.f('ix_app_events_anon_id'), 'app_events', ['anon_id'], unique=False)

    # Content Events
    op.create_table('content_events',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('ts', sa.DateTime(), nullable=False),
        sa.Column('event_type', sa.String(), nullable=False),
        sa.Column('user_id', sa.Uuid(), nullable=True),
        sa.Column('anon_id', sa.String(), nullable=True),
        sa.Column('entity_type', sa.String(), nullable=False),
        sa.Column('entity_id', sa.Uuid(), nullable=False),
        sa.Column('duration_seconds', sa.Integer(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_content_events_ts'), 'content_events', ['ts'], unique=False)
    op.create_index(op.f('ix_content_events_event_type'), 'content_events', ['event_type'], unique=False)
    op.create_index(op.f('ix_content_events_entity_id'), 'content_events', ['entity_id'], unique=False)

    # Purchase Events
    op.create_table('purchase_events',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('ts', sa.DateTime(), nullable=False),
        sa.Column('user_id', sa.Uuid(), nullable=True),
        sa.Column('anon_id', sa.String(), nullable=True),
        sa.Column('amount', sa.Float(), nullable=False),
        sa.Column('currency', sa.String(), nullable=False),
        sa.Column('product_id', sa.String(), nullable=False),
        sa.Column('store', sa.String(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_purchase_events_ts'), 'purchase_events', ['ts'], unique=False)
    op.create_index(op.f('ix_purchase_events_user_id'), 'purchase_events', ['user_id'], unique=False)

    # Aggregates
    op.create_table('analytics_daily_stats',
        sa.Column('date', sa.DateTime(), nullable=False),
        sa.Column('dau', sa.Integer(), nullable=False),
        sa.Column('mau', sa.Integer(), nullable=False),
        sa.Column('new_users', sa.Integer(), nullable=False),
        sa.Column('total_revenue', sa.Float(), nullable=False),
        sa.Column('sessions_count', sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint('date')
    )

    op.create_table('user_cohorts',
        sa.Column('user_id', sa.Uuid(), nullable=False),
        sa.Column('cohort_date', sa.DateTime(), nullable=False),
        sa.Column('source', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('user_id')
    )
    op.create_index(op.f('ix_user_cohorts_cohort_date'), 'user_cohorts', ['cohort_date'], unique=False)

    op.create_table('retention_matrix',
        sa.Column('cohort_date', sa.DateTime(), nullable=False),
        sa.Column('day_n', sa.Integer(), nullable=False),
        sa.Column('retained_count', sa.Integer(), nullable=False),
        sa.Column('percentage', sa.Float(), nullable=False),
        sa.PrimaryKeyConstraint('cohort_date', 'day_n')
    )


def downgrade() -> None:
    op.drop_table('retention_matrix')
    op.drop_index(op.f('ix_user_cohorts_cohort_date'), table_name='user_cohorts')
    op.drop_table('user_cohorts')
    op.drop_table('analytics_daily_stats')
    op.drop_index(op.f('ix_purchase_events_user_id'), table_name='purchase_events')
    op.drop_index(op.f('ix_purchase_events_ts'), table_name='purchase_events')
    op.drop_table('purchase_events')
    op.drop_index(op.f('ix_content_events_entity_id'), table_name='content_events')
    op.drop_index(op.f('ix_content_events_event_type'), table_name='content_events')
    op.drop_index(op.f('ix_content_events_ts'), table_name='content_events')
    op.drop_table('content_events')
    op.drop_index(op.f('ix_app_events_anon_id'), table_name='app_events')
    op.drop_index(op.f('ix_app_events_user_id'), table_name='app_events')
    op.drop_index(op.f('ix_app_events_event_type'), table_name='app_events')
    op.drop_index(op.f('ix_app_events_ts'), table_name='app_events')
    op.drop_table('app_events')
