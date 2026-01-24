"""0009_pr10_deletion.py

Revision ID: 0009_pr10_deletion
Revises: 0008_pr9_poi_desc
Create Date: 2026-01-24 17:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = '0009_pr10_deletion'
down_revision: Union[str, None] = '0008_pr9_poi_desc'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('deletion_requests',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('subject_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('subject_id', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('status', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('request_channel', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('idempotency_key', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
        sa.Column('log_json', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('last_error', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_deletion_requests_idempotency_key'), 'deletion_requests', ['idempotency_key'], unique=True)
    op.create_index(op.f('ix_deletion_requests_status'), 'deletion_requests', ['status'], unique=False)
    op.create_index(op.f('ix_deletion_requests_subject_id'), 'deletion_requests', ['subject_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_deletion_requests_subject_id'), table_name='deletion_requests')
    op.drop_index(op.f('ix_deletion_requests_status'), table_name='deletion_requests')
    op.drop_index(op.f('ix_deletion_requests_idempotency_key'), table_name='deletion_requests')
    op.drop_table('deletion_requests')
