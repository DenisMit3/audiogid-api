
import os
import sys
from sqlmodel import SQLModel, create_engine, text

# Load env from .env.prod if present
try:
    with open("../../.env.prod", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#") and "=" in line:
                key, val = line.strip().split("=", 1)
                os.environ[key] = val.strip('"').strip("'")
except FileNotFoundError:
    print(".env.prod not found, assuming env vars set")

db_url = os.getenv("DATABASE_URL")
if not db_url:
    print("DATABASE_URL not found")
    sys.exit(1)

# Ensure SSL for Neon (not needed for local PostgreSQL)
if "sslmode=require" not in db_url and "neon.tech" in db_url:
    db_url += "?sslmode=require"

engine = create_engine(db_url)

# Import models to ensure they are registered
from api.core.models import *

print("Checking tables...")
with engine.connect() as conn:
    # Check if poi_versions exists
    try:
        res = conn.execute(text("SELECT count(*) FROM poi_versions"))
        print("poi_versions exists, count:", res.scalar())
    except Exception as e:
        print("poi_versions MISSING or error:", e)

    # Check AuditLog
    try:
        res = conn.execute(text("SELECT count(*) FROM audit_logs"))
        print("audit_logs exists, count:", res.scalar())
    except Exception as e:
        print("audit_logs MISSING or error:", e)

    # Check AppEvents
    try:
        res = conn.execute(text("SELECT count(*) FROM app_events"))
        print("app_events exists, count:", res.scalar())
    except Exception as e:
        print("app_events MISSING or error:", e)

print("Running create_all to create missing tables...")
SQLModel.metadata.create_all(engine)
print("create_all done.")
