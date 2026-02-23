#!/usr/bin/env python3
"""
Generate a simple nanobanana zoo PNG image and save it as base64 data URL in the database.
"""
import psycopg2
import base64
import io

from PIL import Image, ImageDraw

DB_URL = "postgresql://neondb_owner:npg_mRMN7C3ohGHz@ep-restless-pond-af40wky4-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require"
TOUR_ID = "b2000001-0000-0000-0000-000000000001"

def create_small_png():
    """Create a small PNG zoo image"""
    img = Image.new('RGB', (200, 150), color=(135, 206, 235))
    draw = ImageDraw.Draw(img)
    
    # Grass
    draw.rectangle([0, 90, 200, 150], fill=(34, 139, 34))
    
    # Sun
    draw.ellipse([160, 10, 190, 40], fill=(255, 223, 0))
    
    # Fence
    draw.rectangle([10, 80, 190, 88], fill=(139, 90, 43))
    
    # Goat
    draw.ellipse([40, 95, 90, 125], fill=(255, 255, 255))
    draw.ellipse([25, 85, 50, 110], fill=(255, 255, 255))
    draw.ellipse([32, 90, 38, 96], fill=(0, 0, 0))
    
    # Nanobanana
    draw.ellipse([120, 100, 160, 140], fill=(255, 225, 53))
    draw.ellipse([128, 110, 136, 118], fill=(0, 0, 0))
    draw.ellipse([144, 110, 152, 118], fill=(0, 0, 0))
    draw.arc([132, 120, 148, 132], 0, 180, fill=(0, 0, 0), width=2)
    
    return img

def image_to_data_url(img):
    buffer = io.BytesIO()
    img.save(buffer, format='PNG', optimize=True)
    b64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    return f"data:image/png;base64,{b64}"

def update_database(cover_url):
    print(f"   Data URL length: {len(cover_url)} chars")
    
    conn = psycopg2.connect(DB_URL, connect_timeout=10)
    cur = conn.cursor()
    
    cur.execute("SELECT id, title_ru FROM tour WHERE id = %s", (TOUR_ID,))
    row = cur.fetchone()
    if not row:
        print(f"   Tour {TOUR_ID} not found!")
        conn.close()
        return False
    
    print(f"   Found tour: {row[1]}")
    
    cur.execute("UPDATE tour SET cover_image = %s WHERE id = %s", (cover_url, TOUR_ID))
    conn.commit()
    print("   Updated!")
    
    conn.close()
    return True

def main():
    print("=== Nanobanana Zoo PNG Generator ===\n")
    
    print("1. Creating PNG image...")
    img = create_small_png()
    data_url = image_to_data_url(img)
    
    print("\n2. Updating database...")
    if update_database(data_url):
        print("\n Done!")
    else:
        print("\n Failed!")

if __name__ == "__main__":
    main()
