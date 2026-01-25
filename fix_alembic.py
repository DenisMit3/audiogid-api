from sqlmodel import Session, text
from apps.api.api.core.database import engine

def fix():
    with Session(engine) as session:
        # Check current version
        try:
            res = session.exec(text("SELECT version_num FROM alembic_version")).all()
            print(f"Current version: {res}")
            
            # Force update
            # We want to go back to f3b4c5d6e7f8 (pr15)
            session.exec(text("UPDATE alembic_version SET version_num = 'f3b4c5d6e7f8'"))
            session.commit()
            print("Forced to f3b4c5d6e7f8")
            
            res_after = session.exec(text("SELECT version_num FROM alembic_version")).all()
            print(f"New version: {res_after}")
            
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    fix()
