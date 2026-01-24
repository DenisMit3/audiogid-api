from sqlmodel import create_engine, SQLModel
from .config import config

# Singleton DB Engine
# echo=True only for debugging/preview, strictly controlled in prod
engine = create_engine(config.DATABASE_URL, echo=False)
