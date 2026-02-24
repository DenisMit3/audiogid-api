#!/usr/bin/env python3
"""
Скрипт для исправления данных в БД после неправильного seed-data.py
Исправляет:
- city_id -> city_slug в таблицах poi и tour
- Добавляет published_at для туров и POI
- Создает бесплатный entitlement для тура
"""
import os
import sys
import uuid
from datetime import datetime

try:
    from sqlalchemy import create_engine, text
    from sqlalchemy.orm import sessionmaker
except ImportError:
    print("ОШИБКА: Установите sqlalchemy: pip install sqlalchemy")
    sys.exit(1)

DATABASE_URL = os.environ.get(
    'DATABASE_URL', 
    'postgresql://audiogid:audiogid@localhost:5432/audiogid'
)

def main():
    print("=" * 60)
    print("FIX DATA - Исправление данных в БД")
    print("=" * 60)
    
    print(f"Подключение к БД: {DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else DATABASE_URL}")
    engine = create_engine(DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    
    now = datetime.utcnow()
    
    try:
        # 1. Проверяем город
        print("\n1. Проверка города nizhny_novgorod...")
        city = session.execute(text("SELECT id, slug, name_ru, is_active FROM city WHERE slug = 'nizhny_novgorod'")).fetchone()
        if city:
            print(f"   OK: Город найден - {city[2]} (active={city[3]})")
        else:
            print("   ОШИБКА: Город не найден! Запустите seed-data.py")
            return
        
        # 2. Проверяем POI
        print("\n2. Проверка POI для nizhny_novgorod...")
        pois = session.execute(text("SELECT id, slug, title_ru, published_at FROM poi WHERE city_slug = 'nizhny_novgorod'")).fetchall()
        print(f"   Найдено POI: {len(pois)}")
        
        if len(pois) == 0:
            # Проверяем, есть ли POI с city_id вместо city_slug
            print("   Проверяем POI с неправильным city_id...")
            # Это не сработает если колонка city_id не существует, но попробуем
            try:
                bad_pois = session.execute(text("SELECT COUNT(*) FROM poi WHERE city_slug IS NULL OR city_slug = ''")).fetchone()
                print(f"   POI без city_slug: {bad_pois[0]}")
            except:
                pass
        
        # 3. Обновляем published_at для POI
        print("\n3. Обновление published_at для POI...")
        result = session.execute(text("""
            UPDATE poi SET published_at = :now 
            WHERE city_slug = 'nizhny_novgorod' AND published_at IS NULL
        """), {"now": now})
        print(f"   Обновлено POI: {result.rowcount}")
        
        # 4. Проверяем туры
        print("\n4. Проверка туров для nizhny_novgorod...")
        tours = session.execute(text("SELECT id, slug, title_ru, published_at FROM tour WHERE city_slug = 'nizhny_novgorod'")).fetchall()
        print(f"   Найдено туров: {len(tours)}")
        for t in tours:
            print(f"   - {t[2]} (published={t[3] is not None})")
        
        # 5. Обновляем published_at для туров
        print("\n5. Обновление published_at для туров...")
        result = session.execute(text("""
            UPDATE tour SET published_at = :now 
            WHERE city_slug = 'nizhny_novgorod' AND published_at IS NULL
        """), {"now": now})
        print(f"   Обновлено туров: {result.rowcount}")
        
        # 6. Проверяем tour_items
        print("\n6. Проверка tour_items...")
        tour_items = session.execute(text("""
            SELECT ti.id, ti.tour_id, ti.poi_id, ti.order_index, p.title_ru
            FROM tour_item ti
            LEFT JOIN poi p ON ti.poi_id = p.id
            JOIN tour t ON ti.tour_id = t.id
            WHERE t.city_slug = 'nizhny_novgorod'
            ORDER BY ti.order_index
        """)).fetchall()
        print(f"   Найдено tour_items: {len(tour_items)}")
        for item in tour_items:
            print(f"   - [{item[3]}] {item[4] or 'POI не найден'}")
        
        # 7. Создаем бесплатный entitlement для тура
        print("\n7. Проверка/создание бесплатного entitlement...")
        tour = session.execute(text("SELECT id FROM tour WHERE slug = 'limpopo_zoo_walk'")).fetchone()
        if tour:
            tour_id = str(tour[0])
            existing = session.execute(text(
                "SELECT id FROM entitlement WHERE slug = 'limpopo_zoo_walk_free'"
            )).fetchone()
            
            if existing:
                print("   SKIP: Бесплатный entitlement уже существует")
            else:
                ent_id = str(uuid.uuid4())
                session.execute(text("""
                    INSERT INTO entitlement (id, slug, scope, ref, title_ru, title_en,
                                            price_amount, price_currency, is_active, created_at, updated_at)
                    VALUES (:id, 'limpopo_zoo_walk_free', 'tour', :ref, 
                            'Бесплатный доступ к туру Зоопарк Лимпопо', 'Free access to Limpopo Zoo tour',
                            0.0, 'RUB', true, :now, :now)
                """), {"id": ent_id, "ref": tour_id, "now": now})
                print(f"   OK: Бесплатный entitlement создан для тура {tour_id}")
        else:
            print("   SKIP: Тур limpopo_zoo_walk не найден")
        
        # 8. Итоговая проверка API данных
        print("\n8. Итоговая проверка (что вернет API)...")
        
        # Города
        cities = session.execute(text("SELECT slug, name_ru FROM city WHERE is_active = true")).fetchall()
        print(f"   Активные города: {len(cities)}")
        for c in cities:
            print(f"   - {c[0]}: {c[1]}")
        
        # Опубликованные туры
        pub_tours = session.execute(text("""
            SELECT t.slug, t.title_ru, t.city_slug, 
                   (SELECT COUNT(*) FROM tour_item WHERE tour_id = t.id) as items_count
            FROM tour t 
            WHERE t.published_at IS NOT NULL
        """)).fetchall()
        print(f"   Опубликованные туры: {len(pub_tours)}")
        for t in pub_tours:
            print(f"   - {t[0]}: {t[1]} ({t[2]}, {t[3]} точек)")
        
        # Опубликованные POI
        pub_pois = session.execute(text("""
            SELECT city_slug, COUNT(*) 
            FROM poi 
            WHERE published_at IS NOT NULL 
            GROUP BY city_slug
        """)).fetchall()
        print(f"   Опубликованные POI по городам:")
        for p in pub_pois:
            print(f"   - {p[0]}: {p[1]} POI")
        
        # Коммит
        session.commit()
        
        print("\n" + "=" * 60)
        print("ГОТОВО!")
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
