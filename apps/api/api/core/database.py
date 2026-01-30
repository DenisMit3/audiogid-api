from sqlmodel import create_engine, SQLModel
from .config import config

# Singleton DB Engine
# echo=True only for debugging/preview, strictly controlled in prod
from sqlalchemy.pool import NullPool

# Singleton DB Engine
# Use NullPool for serverless environments (Vercel) to avoid connection leaks
engine = create_engine(
    config.DATABASE_URL, 
    echo=False,
    poolclass=NullPool,
    pool_pre_ping=True
)

