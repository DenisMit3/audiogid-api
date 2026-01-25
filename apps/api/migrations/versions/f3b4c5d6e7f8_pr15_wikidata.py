"""pr15_wikidata_schema

Revision ID: f3b4c5d6e7f8
Revises: e5a6b272c889
Create Date: 2026-01-25 20:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = 'f3b4c5d6e7f8'
down_revision: Union[str, None] = 'e5a6b272c889'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('poi', sa.Column('wikidata_id', sqlmodel.sql.sqltypes.AutoString(), nullable=True))
    op.add_column('poi', sa.Column('confidence_score', sa.Float(), nullable=False, server_default="0.0"))
    op.create_index(op.f('ix_poi_wikidata_id'), 'poi', ['wikidata_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_poi_wikidata_id'), table_name='poi')
    op.drop_column('poi', 'confidence_score')
    op.drop_column('poi', 'wikidata_id')
