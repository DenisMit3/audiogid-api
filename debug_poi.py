from sqlmodel import Session, select
from apps.api.api.core.database import engine
from apps.api.api.core.models import Poi
import uuid

def check_poi():
    with Session(engine) as session:
        # ID Канта из логов
        poi_id = uuid.UUID("9b3a97d4-cb2c-46f0-bee3-61b4bb57eef3")
        poi = session.get(Poi, poi_id)
        print(f"POI Found: {poi.title_ru}")
        print(f"Bullets Type: {type(poi.preview_bullets)}")
        print(f"Bullets Value: {poi.preview_bullets}")
        
        # Попытка дампа, как в API
        try:
            dump = poi.model_dump()
            print("Model dump successful")
        except Exception as e:
            print(f"Model dump failed: {e}")

if __name__ == "__main__":
    check_poi()
