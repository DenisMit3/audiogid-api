"""fix audit logs and merge

Revision ID: fix_audit_logs_and_merge
Revises: merge_heads_2026, 2026_optimize_indexes
Create Date: 2026-01-31 14:10:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

# revision identifiers, used by Alembic.
revision: str = 'fix_audit_logs_and_merge'
down_revision: Union[str, None] = ('merge_heads_2026', '2026_optimize_indexes')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add missing columns to audit_logs
    op.add_column('audit_logs', sa.Column('ip_address', sqlmodel.sql.sqltypes.AutoString(), nullable=True))
    op.add_column('audit_logs', sa.Column('user_agent', sqlmodel.sql.sqltypes.AutoString(), nullable=True))
    op.add_column('audit_logs', sa.Column('diff_json', sqlmodel.sql.sqltypes.AutoString(), nullable=True))


def downgrade() -> None:
    op.drop_column('audit_logs', 'diff_json')
    op.drop_column('audit_logs', 'user_agent')
    op.drop_column('audit_logs', 'ip_address')
