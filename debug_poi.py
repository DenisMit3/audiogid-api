from sqlmodel import Session, select
from apps.api.api.core.database import engine
from apps.api.api.core.models import Poi
import uuid

def check_poi():
    with Session(engine) as session:
        # ID Канта из логов
        poi_id = uuid.UUID("ea91aa3f-fd4a-4486-a886-4df0a49db8ed")
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
