#!/usr/bin/env python3
"""
Скрипт для создания тура "Контактный зоопарк Лимпопо" в Нижнем Новгороде
"""
import requests
import json
import os

# API Configuration
API_BASE = os.environ.get('API_BASE', 'http://localhost:8000/v1')
ADMIN_EMAIL = os.environ.get('ADMIN_EMAIL', 'admin@audiogid.app')
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin123')

def get_token():
    """Получить токен авторизации"""
    resp = requests.post(f"{API_BASE}/auth/login", json={
        "email": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD
    })
    if resp.status_code != 200:
        print(f"Login failed: {resp.status_code} - {resp.text}")
        return None
    return resp.json().get('access_token')

def api_call(method, endpoint, token, data=None):
    """Универсальный API вызов"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = f"{API_BASE}{endpoint}"
    
    if method == 'GET':
        resp = requests.get(url, headers=headers)
    elif method == 'POST':
        resp = requests.post(url, headers=headers, json=data)
    elif method == 'PATCH':
        resp = requests.patch(url, headers=headers, json=data)
    else:
        raise ValueError(f"Unknown method: {method}")
    
    return resp

def main():
    print("=== Создание тура 'Зоопарк Лимпопо' ===\n")
    
    # 1. Авторизация
    print("1. Авторизация...")
    token = get_token()
    if not token:
        print("   ОШИБКА: Не удалось получить токен")
        return
    print(f"   OK: Токен получен")
    
    # 2. Проверка/создание города Нижний Новгород
    print("\n2. Проверка города Нижний Новгород...")
    resp = api_call('GET', '/admin/cities?search=nizhny', token)
    cities = resp.json().get('items', [])
    
    city_slug = 'nizhny_novgorod'
    city_exists = any(c['slug'] == city_slug for c in cities)
    
    if not city_exists:
        print("   Город не найден, создаем...")
        city_data = {
            "slug": city_slug,
            "name_ru": "Нижний Новгород",
            "name_en": "Nizhny Novgorod",
            "description_ru": "Нижний Новгород - пятый по численности населения город России, расположенный на слиянии рек Оки и Волги.",
            "description_en": "Nizhny Novgorod is the fifth largest city in Russia, located at the confluence of the Oka and Volga rivers.",
            "bounds_lat_min": 56.20,
            "bounds_lat_max": 56.40,
            "bounds_lon_min": 43.80,
            "bounds_lon_max": 44.10,
            "default_zoom": 12.0,
            "timezone": "Europe/Moscow",
            "is_active": True
        }
        resp = api_call('POST', '/admin/cities', token, city_data)
        if resp.status_code in [200, 201]:
            print(f"   OK: Город создан")
        else:
            print(f"   ОШИБКА: {resp.status_code} - {resp.text}")
            return
    else:
        print(f"   OK: Город уже существует")
    
    # 3. Создание POI (точек интереса) для зоопарка
    print("\n3. Создание точек интереса (POI)...")
    
    pois_data = [
        {
            "city_slug": city_slug,
            "title_ru": "Зоопарк Лимпопо - Главный вход",
            "title_en": "Limpopo Zoo - Main Entrance",
            "description_ru": "Главный вход в зоопарк Лимпопо. Здесь расположены кассы и информационный центр. Зоопарк работает со вторника по воскресенье с 9:00 до 17:00. Стоимость билетов: взрослый - 1100 руб., льготный - 700 руб.",
            "description_en": "Main entrance to Limpopo Zoo. Ticket office and information center are located here.",
            "category": "attraction",
            "lat": 56.2847,
            "lon": 43.9892,
            "address": "ул. Ярошенко, д. 7Б, Нижний Новгород"
        },
        {
            "city_slug": city_slug,
            "title_ru": "Вольер бенгальских тигров",
            "title_en": "Bengal Tigers Enclosure",
            "description_ru": "Один из главных аттракционов зоопарка - вольер с бенгальскими тиграми. Эти величественные хищники являются одними из самых крупных представителей семейства кошачьих. В зоопарке Лимпопо можно наблюдать за их поведением в условиях, максимально приближенных к естественной среде обитания.",
            "description_en": "One of the main attractions - the Bengal tigers enclosure.",
            "category": "attraction",
            "lat": 56.2852,
            "lon": 43.9898,
            "address": "Зоопарк Лимпопо, территория"
        },
        {
            "city_slug": city_slug,
            "title_ru": "Контактная площадка",
            "title_en": "Petting Zoo Area",
            "description_ru": "Контактная площадка - любимое место детей и взрослых! Здесь можно погладить и покормить домашних животных: кроликов, козочек, овечек, морских свинок. Корм для животных можно приобрести на месте. Это отличная возможность для детей познакомиться с животными поближе.",
            "description_en": "Petting zoo area where visitors can interact with domestic animals.",
            "category": "attraction",
            "lat": 56.2855,
            "lon": 43.9885,
            "address": "Зоопарк Лимпопо, контактная зона"
        },
        {
            "city_slug": city_slug,
            "title_ru": "Ботанический сад Амазония",
            "title_en": "Amazonia Botanical Garden",
            "description_ru": "Уникальный крытый комплекс 'Амазония' включает ботанический сад с тропическими растениями и экспозицию 'Ночной мир' с ночными животными. Комплексный билет (зоопарк + Амазония): взрослый - 1300 руб., льготный - 900 руб.",
            "description_en": "Unique indoor complex with tropical plants and nocturnal animals exhibition.",
            "category": "attraction",
            "lat": 56.2849,
            "lon": 43.9880,
            "address": "Зоопарк Лимпопо, комплекс Амазония"
        },
        {
            "city_slug": city_slug,
            "title_ru": "Вольер с жирафами",
            "title_en": "Giraffes Enclosure",
            "description_ru": "Жирафы - самые высокие животные на планете. В зоопарке Лимпопо можно увидеть этих грациозных животных и узнать интересные факты об их жизни в дикой природе Африки.",
            "description_en": "Giraffes enclosure - see the tallest animals on the planet.",
            "category": "attraction",
            "lat": 56.2858,
            "lon": 43.9895,
            "address": "Зоопарк Лимпопо, африканская зона"
        },
        {
            "city_slug": city_slug,
            "title_ru": "Обезьянник - Приматы",
            "title_en": "Primates House",
            "description_ru": "В обезьяннике зоопарка обитают различные виды приматов: суматранские орангутаны, капуцины, лемуры вари и другие. Наблюдение за обезьянами - одно из самых увлекательных занятий для посетителей всех возрастов.",
            "description_en": "Primates house with orangutans, capuchins, lemurs and other species.",
            "category": "attraction",
            "lat": 56.2845,
            "lon": 43.9890,
            "address": "Зоопарк Лимпопо, дом приматов"
        }
    ]
    
    created_poi_ids = []
    
    for i, poi_data in enumerate(pois_data, 1):
        print(f"   Создание POI {i}/{len(pois_data)}: {poi_data['title_ru'][:40]}...")
        resp = api_call('POST', '/admin/pois', token, poi_data)
        if resp.status_code in [200, 201]:
            poi_id = resp.json().get('id')
            created_poi_ids.append(poi_id)
            print(f"      OK: ID = {poi_id}")
            
            # Публикуем POI
            pub_resp = api_call('POST', f'/admin/pois/{poi_id}/publish', token)
            if pub_resp.status_code in [200, 201]:
                print(f"      OK: POI опубликован")
            else:
                print(f"      WARN: Не удалось опубликовать: {pub_resp.status_code}")
        else:
            print(f"      ОШИБКА: {resp.status_code} - {resp.text[:100]}")
    
    if len(created_poi_ids) < 3:
        print("\n   ОШИБКА: Создано недостаточно POI для тура")
        return
    
    # 4. Создание тура
    print("\n4. Создание тура...")
    tour_data = {
        "city_slug": city_slug,
        "title_ru": "Зоопарк Лимпопо - семейная прогулка",
        "title_en": "Limpopo Zoo - Family Walk",
        "description_ru": "Увлекательная прогулка по зоопарку Лимпопо в Нижнем Новгороде. Вы увидите бенгальских тигров, жирафов, обезьян и многих других животных. Особенно понравится детям контактная площадка, где можно погладить и покормить животных. Продолжительность: около 2 часов.",
        "description_en": "An exciting walk through Limpopo Zoo in Nizhny Novgorod.",
        "duration_minutes": 120,
        "tour_type": "walking",
        "difficulty": "easy"
    }
    
    resp = api_call('POST', '/admin/tours', token, tour_data)
    if resp.status_code not in [200, 201]:
        print(f"   ОШИБКА создания тура: {resp.status_code} - {resp.text}")
        return
    
    tour_id = resp.json().get('id')
    print(f"   OK: Тур создан, ID = {tour_id}")
    
    # 5. Добавление точек в маршрут тура
    print("\n5. Добавление точек в маршрут...")
    
    transitions = [
        "Начните прогулку от главного входа. Пройдите через турникеты и следуйте по главной аллее.",
        "От входа идите прямо около 100 метров до вольера с тиграми. Он будет справа от вас.",
        "После тигров поверните налево и пройдите к контактной площадке - любимому месту детей!",
        "От контактной площадки пройдите к крытому комплексу Амазония - он находится в 50 метрах.",
        "Выйдя из Амазонии, направляйтесь к вольеру с жирафами в африканской зоне.",
        "Завершите прогулку посещением обезьянника - он находится недалеко от выхода."
    ]
    
    for i, poi_id in enumerate(created_poi_ids):
        print(f"   Добавление точки {i+1}/{len(created_poi_ids)}...")
        item_data = {
            "poi_id": poi_id,
            "order_index": i,
            "transition_text_ru": transitions[i] if i < len(transitions) else None,
            "duration_seconds": 600  # 10 минут на каждую точку
        }
        resp = api_call('POST', f'/admin/tours/{tour_id}/items', token, item_data)
        if resp.status_code in [200, 201]:
            print(f"      OK")
        else:
            print(f"      ОШИБКА: {resp.status_code} - {resp.text[:100]}")
    
    # 6. Публикация тура
    print("\n6. Публикация тура...")
    resp = api_call('POST', f'/admin/tours/{tour_id}/publish', token)
    if resp.status_code in [200, 201]:
        print(f"   OK: Тур опубликован!")
    else:
        print(f"   WARN: {resp.status_code} - {resp.text}")
        # Проверим причину
        check_resp = api_call('GET', f'/admin/tours/{tour_id}/publish_check', token)
        if check_resp.status_code == 200:
            check = check_resp.json()
            print(f"   Проблемы публикации: {check.get('issues', [])}")
    
    print("\n" + "="*50)
    print(f"ГОТОВО!")
    print(f"Тур ID: {tour_id}")
    print(f"Город: {city_slug}")
    print(f"Точек в маршруте: {len(created_poi_ids)}")
    print("="*50)

if __name__ == "__main__":
    main()
