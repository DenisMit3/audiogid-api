from apps.api.api.core.database import engine
from apps.api.api.core.models import Job
from sqlmodel import Session, select
from datetime import datetime

def reset_todays_job():
    date_str = datetime.utcnow().strftime("%Y-%m-%d")
    key = f"osm_import|kaliningrad_city|{date_str}"
    
    with Session(engine) as session:
        statement = select(Job).where(Job.idempotency_key == key)
        job = session.exec(statement).first()
        
        if job:
            print(f"Found job {job.id} with status {job.status}. Deleting...")
            session.delete(job)
            session.commit()
            print("Job deleted.")
        else:
            print("No job found for today.")

if __name__ == "__main__":
    reset_todays_job()
