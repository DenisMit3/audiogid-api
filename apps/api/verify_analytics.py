
import sys
import os
from sqlmodel import Session, select, func
from api.core.database import engine
from api.core.models import AppEvent, ContentEvent, PurchaseEvent

def check_analytics():
    print("Checking Analytics Tables...")
    try:
        with Session(engine) as session:
            # Check if tables exist by querying
            app_count = session.exec(select(func.count(AppEvent.id))).one()
            content_count = session.exec(select(func.count(ContentEvent.id))).one()
            purchase_count = session.exec(select(func.count(PurchaseEvent.id))).one()
            print(f"AppEvents: {app_count}")
            print(f"ContentEvents: {content_count}")
            print(f"PurchaseEvents: {purchase_count}")
            
            # Identify if tables are queryable
            print("Analytics Tables Verified.")
    except Exception as e:
        print(f"Error checking analytics: {e}")

if __name__ == "__main__":
    check_analytics()
