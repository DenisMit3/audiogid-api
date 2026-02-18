
import os
import sys
from sqlmodel import create_engine, text, Session

# Load env from .env.prod
try:
    with open(".env.prod", "r") as f:
        for line in f:
            if line.strip() and not line.startswith("#") and "=" in line:
                key, val = line.strip().split("=", 1)
                os.environ[key] = val.strip('"').strip("'")
except FileNotFoundError:
    print(".env.prod not found")

db_url = os.getenv("DATABASE_URL")
if not db_url:
    print("DATABASE_URL not found")
    sys.exit(1)

if "sslmode=require" not in db_url and "neon.tech" in db_url:
    db_url += "?sslmode=require"

engine = create_engine(db_url)

print("Fixing schema remotely...")

statements = [
    "ALTER TABLE poi ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE",
    "ALTER TABLE poi ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITHOUT TIME ZONE",
    
    # Just in case tour also missed it
    "ALTER TABLE tour ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE",
    "ALTER TABLE tour ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITHOUT TIME ZONE",
    
    # Indexes (optional but good)
    "CREATE INDEX IF NOT EXISTS ix_poi_is_deleted ON poi (is_deleted)",
    "CREATE INDEX IF NOT EXISTS ix_tour_is_deleted ON tour (is_deleted)"
]

with Session(engine) as session:
    for stmt in statements:
        try:
            print(f"Executing: {stmt}")
            session.exec(text(stmt))
            session.commit()
            print("Done.")
        except Exception as e:
            session.rollback()
            print(f"Failed: {e}")

print("Schema fix complete.")
