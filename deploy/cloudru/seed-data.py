#!/usr/bin/env python3
"""
Скрипт для заполнения базы данных начальными данными (seed data)
Запускать после миграций: python seed-data.py

Создает:
- Город Нижний Новгород
- Тур "Зоопарк Лимпопо" с 6 POI
- Entitlements для городов
"""
import os
import sys
import uuid
from datetime import datetime

# Добавляем путь к API для импорта моделей
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from sqlalchemy import create_engine, text
    from sqlalchemy.orm import sessionmaker
except ImportError:
    print("ОШИБКА: Установите sqlalchemy: pip install sqlalchemy")
    sys.exit(1)

# =============================================================================
# Конфигурация
# =============================================================================
DATABASE_URL = os.environ.get(
    'DATABASE_URL', 
    'postgresql://audiogid:audiogid@localhost:5432/audiogid'
)

# =============================================================================
# Данные для заполнения
# =============================================================================

CITY_NIZHNY = {
    "id": str(uuid.uuid4()),
    "slug": "nizhny_novgorod",
    "name_ru": "Нижний Новгород",
    "name_en": "Nizhny Novgorod",
    "description_ru": "Нижний Новгород - пятый по численности населения город России, расположенный на слиянии рек Оки и Волги. Город с богатой историей, основанный в 1221 году.",
    "description_en": "Nizhny Novgorod is the fifth largest city in Russia, located at the confluence of the Oka and Volga rivers.",
    "bounds_lat_min": 56.20,
    "bounds_lat_max": 56.40,
    "bounds_lon_min": 43.80,
    "bounds_lon_max": 44.10,
    "default_zoom": 12.0,
    "timezone": "Europe/Moscow",
    "is_active": True
}

POIS_LIMPOPO = [
    {
        "slug": "limpopo_entrance",
        "title_ru": "Зоопарк Лимпопо - Главный вход",
        "title_en": "Limpopo Zoo - Main Entrance",
        "description_ru": "Главный вход в зоопарк Лимпопо. Здесь расположены кассы и информационный центр. Зоопарк работает со вторника по воскресенье с 9:00 до 17:00. Стоимость билетов: взрослый - 1100 руб., льготный - 700 руб.",
        "description_en": "Main entrance to Limpopo Zoo. Ticket office and information center are located here.",
        "category": "attraction",
        "lat": 56.2847,
        "lon": 43.9892,
        "address": "ул. Ярошенко, д. 7Б, Нижний Новгород",
        "status": "published"
    },
    {
        "slug": "limpopo_tigers",
        "title_ru": "Вольер бенгальских тигров",
        "title_en": "Bengal Tigers Enclosure",
        "description_ru": "Один из главных аттракционов зоопарка - вольер с бенгальскими тиграми. Эти величественные хищники являются одними из самых крупных представителей семейства кошачьих.",
        "description_en": "One of the main attractions - the Bengal tigers enclosure.",
        "category": "attraction",
        "lat": 56.2852,
        "lon": 43.9898,
        "address": "Зоопарк Лимпопо, территория",
        "status": "published"
    },
    {
        "slug": "limpopo_petting",
        "title_ru": "Контактная площадка",
        "title_en": "Petting Zoo Area",
        "description_ru": "Контактная площадка - любимое место детей и взрослых! Здесь можно погладить и покормить домашних животных: кроликов, козочек, овечек, морских свинок.",
        "description_en": "Petting zoo area where visitors can interact with domestic animals.",
        "category": "attraction",
        "lat": 56.2855,
        "lon": 43.9885,
        "address": "Зоопарк Лимпопо, контактная зона",
        "status": "published"
    },
    {
        "slug": "limpopo_amazonia",
        "title_ru": "Ботанический сад Амазония",
        "title_en": "Amazonia Botanical Garden",
        "description_ru": "Уникальный крытый комплекс 'Амазония' включает ботанический сад с тропическими растениями и экспозицию 'Ночной мир' с ночными животными.",
        "description_en": "Unique indoor complex with tropical plants and nocturnal animals exhibition.",
        "category": "attraction",
        "lat": 56.2849,
        "lon": 43.9880,
        "address": "Зоопарк Лимпопо, комплекс Амазония",
        "status": "published"
    },
    {
        "slug": "limpopo_giraffes",
        "title_ru": "Вольер с жирафами",
        "title_en": "Giraffes Enclosure",
        "description_ru": "Жирафы - самые высокие животные на планете. В зоопарке Лимпопо можно увидеть этих грациозных животных и узнать интересные факты об их жизни.",
        "description_en": "Giraffes enclosure - see the tallest animals on the planet.",
        "category": "attraction",
        "lat": 56.2858,
        "lon": 43.9895,
        "address": "Зоопарк Лимпопо, африканская зона",
        "status": "published"
    },
    {
        "slug": "limpopo_primates",
        "title_ru": "Обезьянник - Приматы",
        "title_en": "Primates House",
        "description_ru": "В обезьяннике зоопарка обитают различные виды приматов: суматранские орангутаны, капуцины, лемуры вари и другие.",
        "description_en": "Primates house with orangutans, capuchins, lemurs and other species.",
        "category": "attraction",
        "lat": 56.2845,
        "lon": 43.9890,
        "address": "Зоопарк Лимпопо, дом приматов",
        "status": "published"
    }
]

TOUR_LIMPOPO = {
    "slug": "limpopo_zoo_walk",
    "title_ru": "Зоопарк Лимпопо - семейная прогулка",
    "title_en": "Limpopo Zoo - Family Walk",
    "description_ru": "Увлекательная прогулка по зоопарку Лимпопо в Нижнем Новгороде. Вы увидите бенгальских тигров, жирафов, обезьян и многих других животных. Особенно понравится детям контактная площадка. Продолжительность: около 2 часов.",
    "description_en": "An exciting walk through Limpopo Zoo in Nizhny Novgorod.",
    "duration_minutes": 120,
    "tour_type": "walking",
    "difficulty": "easy",
    "status": "published"
}

TOUR_TRANSITIONS = [
    "Начните прогулку от главного входа. Пройдите через турникеты и следуйте по главной аллее.",
    "От входа идите прямо около 100 метров до вольера с тиграми. Он будет справа от вас.",
    "После тигров поверните налево и пройдите к контактной площадке - любимому месту детей!",
    "От контактной площадки пройдите к крытому комплексу Амазония - он находится в 50 метрах.",
    "Выйдя из Амазонии, направляйтесь к вольеру с жирафами в африканской зоне.",
    "Завершите прогулку посещением обезьянника - он находится недалеко от выхода."
]

ENTITLEMENTS = [
    {
        "slug": "kaliningrad_city_access",
        "scope": "city",
        "ref": "kaliningrad_city",
        "title_ru": "Доступ к Калининграду (Все туры)",
        "title_en": "Kaliningrad Access (All Tours)",
        "price_amount": 499.0,
        "price_currency": "RUB",
        "is_active": True
    },
    {
        "slug": "nizhny_novgorod_city_access",
        "scope": "city",
        "ref": "nizhny_novgorod",
        "title_ru": "Доступ к Нижнему Новгороду (Все туры)",
        "title_en": "Nizhny Novgorod Access (All Tours)",
        "price_amount": 499.0,
        "price_currency": "RUB",
        "is_active": True
    }
]

# =============================================================================
# Функции
# =============================================================================

def create_engine_safe():
    """Создать подключение к БД"""
    print(f"Подключение к БД: {DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else DATABASE_URL}")
    return create_engine(DATABASE_URL)

def check_exists(session, table, column, value):
    """Проверить существование записи"""
    result = session.execute(
        text(f"SELECT 1 FROM {table} WHERE {column} = :value LIMIT 1"),
        {"value": value}
    )
    return result.fetchone() is not None

def seed_city(session):
    """Создать город Нижний Новгород"""
    print("\n1. Создание города Нижний Новгород...")
    
    if check_exists(session, "city", "slug", CITY_NIZHNY["slug"]):
        print("   SKIP: Город уже существует")
        # Получаем ID существующего города
        result = session.execute(
            text("SELECT id FROM city WHERE slug = :slug"),
            {"slug": CITY_NIZHNY["slug"]}
        )
        return str(result.fetchone()[0])
    
    city_id = CITY_NIZHNY["id"]
    now = datetime.utcnow()
    
    session.execute(text("""
        INSERT INTO city (id, slug, name_ru, name_en, description_ru, description_en,
                         bounds_lat_min, bounds_lat_max, bounds_lon_min, bounds_lon_max,
                         default_zoom, timezone, is_active, created_at, updated_at)
        VALUES (:id, :slug, :name_ru, :name_en, :description_ru, :description_en,
                :bounds_lat_min, :bounds_lat_max, :bounds_lon_min, :bounds_lon_max,
                :default_zoom, :timezone, :is_active, :created_at, :updated_at)
    """), {
        **CITY_NIZHNY,
        "created_at": now,
        "updated_at": now
    })
    
    print(f"   OK: Город создан (ID: {city_id})")
    return city_id

def seed_pois(session, city_id):
    """Создать POI для зоопарка"""
    print("\n2. Создание точек интереса (POI)...")
    
    poi_ids = []
    now = datetime.utcnow()
    
    for i, poi in enumerate(POIS_LIMPOPO, 1):
        if check_exists(session, "poi", "slug", poi["slug"]):
            print(f"   SKIP: POI '{poi['slug']}' уже существует")
            result = session.execute(
                text("SELECT id FROM poi WHERE slug = :slug"),
                {"slug": poi["slug"]}
            )
            poi_ids.append(str(result.fetchone()[0]))
            continue
        
        poi_id = str(uuid.uuid4())
        
        session.execute(text("""
            INSERT INTO poi (id, city_id, slug, title_ru, title_en, description_ru, description_en,
                            category, lat, lon, address, status, created_at, updated_at)
            VALUES (:id, :city_id, :slug, :title_ru, :title_en, :description_ru, :description_en,
                    :category, :lat, :lon, :address, :status, :created_at, :updated_at)
        """), {
            "id": poi_id,
            "city_id": city_id,
            **poi,
            "created_at": now,
            "updated_at": now
        })
        
        poi_ids.append(poi_id)
        print(f"   OK: POI {i}/{len(POIS_LIMPOPO)} - {poi['title_ru'][:30]}...")
    
    return poi_ids

def seed_tour(session, city_id, poi_ids):
    """Создать тур"""
    print("\n3. Создание тура...")
    
    if check_exists(session, "tour", "slug", TOUR_LIMPOPO["slug"]):
        print("   SKIP: Тур уже существует")
        result = session.execute(
            text("SELECT id FROM tour WHERE slug = :slug"),
            {"slug": TOUR_LIMPOPO["slug"]}
        )
        return str(result.fetchone()[0])
    
    tour_id = str(uuid.uuid4())
    now = datetime.utcnow()
    
    session.execute(text("""
        INSERT INTO tour (id, city_id, slug, title_ru, title_en, description_ru, description_en,
                         duration_minutes, tour_type, difficulty, status, created_at, updated_at)
        VALUES (:id, :city_id, :slug, :title_ru, :title_en, :description_ru, :description_en,
                :duration_minutes, :tour_type, :difficulty, :status, :created_at, :updated_at)
    """), {
        "id": tour_id,
        "city_id": city_id,
        **TOUR_LIMPOPO,
        "created_at": now,
        "updated_at": now
    })
    
    print(f"   OK: Тур создан (ID: {tour_id})")
    
    # Добавляем точки в маршрут
    print("\n4. Добавление точек в маршрут тура...")
    
    for i, poi_id in enumerate(poi_ids):
        item_id = str(uuid.uuid4())
        transition = TOUR_TRANSITIONS[i] if i < len(TOUR_TRANSITIONS) else None
        
        session.execute(text("""
            INSERT INTO tour_item (id, tour_id, poi_id, order_index, transition_text_ru,
                                  duration_seconds, created_at, updated_at)
            VALUES (:id, :tour_id, :poi_id, :order_index, :transition_text_ru,
                    :duration_seconds, :created_at, :updated_at)
        """), {
            "id": item_id,
            "tour_id": tour_id,
            "poi_id": poi_id,
            "order_index": i,
            "transition_text_ru": transition,
            "duration_seconds": 600,
            "created_at": now,
            "updated_at": now
        })
        print(f"   OK: Точка {i+1}/{len(poi_ids)} добавлена")
    
    return tour_id

def seed_entitlements(session):
    """Создать entitlements"""
    print("\n5. Создание entitlements...")
    
    now = datetime.utcnow()
    
    for ent in ENTITLEMENTS:
        if check_exists(session, "entitlement", "slug", ent["slug"]):
            print(f"   SKIP: Entitlement '{ent['slug']}' уже существует")
            continue
        
        ent_id = str(uuid.uuid4())
        
        session.execute(text("""
            INSERT INTO entitlement (id, slug, scope, ref, title_ru, title_en,
                                    price_amount, price_currency, is_active, created_at, updated_at)
            VALUES (:id, :slug, :scope, :ref, :title_ru, :title_en,
                    :price_amount, :price_currency, :is_active, :created_at, :updated_at)
        """), {
            "id": ent_id,
            **ent,
            "created_at": now,
            "updated_at": now
        })
        
        print(f"   OK: Entitlement '{ent['slug']}' создан")

def main():
    """Основная функция"""
    print("=" * 60)
    print("SEED DATA - Заполнение базы данных")
    print("=" * 60)
    
    engine = create_engine_safe()
    Session = sessionmaker(bind=engine)
    session = Session()
    
    try:
        # Создаем данные
        city_id = seed_city(session)
        poi_ids = seed_pois(session, city_id)
        tour_id = seed_tour(session, city_id, poi_ids)
        seed_entitlements(session)
        
        # Коммитим транзакцию
        session.commit()
        
        print("\n" + "=" * 60)
        print("ГОТОВО!")
        print("=" * 60)
        print(f"Город: {CITY_NIZHNY['name_ru']} (ID: {city_id})")
        print(f"POI создано: {len(poi_ids)}")
        print(f"Тур: {TOUR_LIMPOPO['title_ru']} (ID: {tour_id})")
        print(f"Entitlements: {len(ENTITLEMENTS)}")
        print("=" * 60)
        
    except Exception as e:
        session.rollback()
        print(f"\nОШИБКА: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        session.close()

if __name__ == "__main__":
    main()
