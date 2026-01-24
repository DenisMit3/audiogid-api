"""0008_pr9_poi_desc.py

Revision ID: 0008_pr9_poi_desc
Revises: 0007_pr8_purchases
Create Date: 2026-01-24 16:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import sqlmodel

revision: str = '0008_pr9_poi_desc'
down_revision: Union[str, None] = '0007_pr8_purchases'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('poi', sa.Column('description_ru', sqlmodel.sql.sqltypes.AutoString(), nullable=True))


def downgrade() -> None:
    op.drop_column('poi', 'description_ru')
