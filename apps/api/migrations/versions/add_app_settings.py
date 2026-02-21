"""Add app_settings table

Revision ID: add_app_settings
Revises: 
Create Date: 2026-02-19

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = 'add_app_settings'
down_revision = None
branch_labels = ('app_settings',)
depends_on = None

def upgrade():
    # Create app_settings table
    op.create_table(
        'app_settings',
        sa.Column('key', sa.String(), nullable=False),
        sa.Column('value', sa.String(), nullable=False, server_default=''),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_by', sa.UUID(), nullable=True),
        sa.PrimaryKeyConstraint('key')
    )

def downgrade():
    op.drop_table('app_settings')
