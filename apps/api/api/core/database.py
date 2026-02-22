from sqlmodel import create_engine, SQLModel
from .config import config

# Singleton DB Engine
from sqlalchemy.pool import NullPool

# For Neon: use pooled URL with psycopg2 driver
# The unpooled URL has cold start issues on free tier
db_url = config.DATABASE_URL

engine = create_engine(
    db_url, 
    echo=False,
    poolclass=NullPool,
    connect_args={
        "connect_timeout": 60
    }
)

