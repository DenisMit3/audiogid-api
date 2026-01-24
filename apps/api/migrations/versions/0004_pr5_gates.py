"""0004_pr5_gates.py

Revision ID: 0004_pr5_gates
Revises: 0003_pr2_ingestion
Create Date: 2026-01-24 14:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = '0004_pr5_gates'
down_revision: Union[str, None] = '0003_pr2_ingestion'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Update POI table
    op.add_column('poi', sa.Column('published_at', sa.DateTime(), nullable=True))
    op.create_index(op.f('ix_poi_published_at'), 'poi', ['published_at'], unique=False)
    with op.batch_alter_table('poi') as batch_op:
        batch_op.drop_column('is_published')

    # 2. Poi Sources
    op.create_table('poi_sources',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('poi_id', sa.Uuid(), nullable=False),
        sa.Column('name', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('url', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.ForeignKeyConstraint(['poi_id'], ['poi.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_poi_sources_poi_id'), 'poi_sources', ['poi_id'], unique=False)

    # 3. Poi Media
    op.create_table('poi_media',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('poi_id', sa.Uuid(), nullable=False),
        sa.Column('url', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('media_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('license_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('author', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('source_page_url', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.ForeignKeyConstraint(['poi_id'], ['poi.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_poi_media_poi_id'), 'poi_media', ['poi_id'], unique=False)

    # 4. Audit Logs (Updated Logic)
    op.create_table('audit_logs',
        sa.Column('id', sa.Uuid(), nullable=False),
        sa.Column('action', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('target_id', sa.Uuid(), nullable=False),
        sa.Column('actor_type', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        # Renamed/New column: fingerprint
        sa.Column('actor_fingerprint', sqlmodel.sql.sqltypes.AutoString(), nullable=False),
        sa.Column('trace_id', sqlmodel.sql.sqltypes.AutoString(), nullable=True),
        sa.Column('timestamp', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_audit_logs_target_id'), 'audit_logs', ['target_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_audit_logs_target_id'), table_name='audit_logs')
    op.drop_table('audit_logs')
    op.drop_index(op.f('ix_poi_media_poi_id'), table_name='poi_media')
    op.drop_table('poi_media')
    op.drop_index(op.f('ix_poi_sources_poi_id'), table_name='poi_sources')
    op.drop_table('poi_sources')
    
    with op.batch_alter_table('poi') as batch_op:
        batch_op.add_column(sa.Column('is_published', sa.Boolean(), nullable=False, server_default=sa.text('false')))
        batch_op.drop_index(op.f('ix_poi_published_at'))
        batch_op.drop_column('published_at')
