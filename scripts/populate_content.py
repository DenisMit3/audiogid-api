
import requests
import os
import json
import time

# Configuration
API_URL = os.getenv("API_URL", "http://localhost:8000/v1")
ADMIN_TOKEN = os.getenv("ADMIN_API_TOKEN", "your_admin_token_here")

def log(msg):
    print(f"[Populate] {msg}")

def get_headers():
    return {
        "x-admin-token": ADMIN_TOKEN,
        "Content-Type": "application/json"
    }

def enqueue_osm_import(city_slug):
    log(f"Enqueuing OSM Import for {city_slug}...")
    try:
        res = requests.post(
            f"{API_URL}/admin/ingestion/osm/enqueue", 
            json={"city_slug": city_slug}, 
            headers=get_headers()
        )
        if res.status_code in [200, 202]:
            log(f"Success: {res.json()}")
        else:
            log(f"Failed: {res.status_code} - {res.text}")
    except Exception as e:
        log(f"Error: {e}")

def create_featured_tour(city_slug):
    log(f"Creating featured tour for {city_slug}...")
    tour_data = {
        "city_slug": city_slug,
        "title_ru": "Best of Kaliningrad",
        "description_ru": "A specialized tour covering the top sights.",
        "duration_minutes": 120,
        "tour_type": "walking",
        "difficulty": "easy"
    }
    try:
        res = requests.post(f"{API_URL}/admin/tours", json=tour_data, headers=get_headers())
        if res.status_code == 201:
            log(f"Tour Created: {res.json().get('id')}")
        else:
            log(f"Failed to create tour: {res.status_code} - {res.text}")
    except Exception as e:
        log(f"Error creating tour: {e}")

if __name__ == "__main__":
    if ADMIN_TOKEN == "your_admin_token_here":
        log("WARNING: Set ADMIN_API_TOKEN environment variable.")
    
    log("Starting Content Population...")
    
    # 1. Enqueue Imports
    enqueue_osm_import("kaliningrad_city")
    enqueue_osm_import("kaliningrad_oblast")
    
    # 2. Create Featured Tours
    create_featured_tour("kaliningrad_city")
    create_featured_tour("kaliningrad_oblast")
    
    log("Content Population Initiated.")
