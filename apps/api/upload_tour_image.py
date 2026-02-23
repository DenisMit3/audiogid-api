#!/usr/bin/env python3
"""
Upload tour cover image to MinIO and update database.
Run this on the Cloud.ru server where MinIO is running.
"""
import os
import io
import psycopg2
from PIL import Image, ImageDraw, ImageFont
import boto3
from botocore.client import Config

# Configuration
DB_URL = "postgresql://neondb_owner:npg_mRMN7C3ohGHz@ep-restless-pond-af40wky4-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require"
S3_ENDPOINT = "http://localhost:9000"
S3_ACCESS_KEY = "minioadmin"
S3_SECRET_KEY = "minioadmin"
S3_BUCKET = "audiogid"
S3_PUBLIC_URL = "http://82.202.159.64:9000/audiogid"

TOUR_ID = "b2000001-0000-0000-0000-000000000001"

def create_zoo_image():
    """Create a simple zoo-themed placeholder image"""
    # Create image 640x480
    img = Image.new('RGB', (640, 480), color=(135, 206, 235))  # Sky blue
    draw = ImageDraw.Draw(img)
    
    # Draw grass
    draw.rectangle([0, 300, 640, 480], fill=(34, 139, 34))  # Green grass
    
    # Draw sun
    draw.ellipse([520, 30, 600, 110], fill=(255, 223, 0))  # Yellow sun
    
    # Draw fence
    for x in range(50, 600, 60):
        draw.rectangle([x, 250, x+10, 320], fill=(139, 90, 43))  # Brown posts
    draw.rectangle([40, 270, 600, 285], fill=(139, 90, 43))  # Horizontal bar
    
    # Draw a simple goat shape
    # Body
    draw.ellipse([200, 320, 340, 400], fill=(255, 255, 255))  # White body
    # Head
    draw.ellipse([150, 300, 220, 360], fill=(255, 255, 255))
    # Legs
    draw.rectangle([220, 390, 235, 450], fill=(255, 255, 255))
    draw.rectangle([240, 390, 255, 450], fill=(255, 255, 255))
    draw.rectangle([300, 390, 315, 450], fill=(255, 255, 255))
    draw.rectangle([320, 390, 335, 450], fill=(255, 255, 255))
    # Eye
    draw.ellipse([170, 315, 185, 330], fill=(0, 0, 0))
    # Horns
    draw.polygon([(180, 300), (175, 270), (190, 300)], fill=(139, 90, 43))
    draw.polygon([(200, 300), (205, 270), (190, 300)], fill=(139, 90, 43))
    
    # Draw a banana character (nanobanana!)
    # Banana body
    draw.ellipse([400, 350, 480, 440], fill=(255, 225, 53))  # Yellow
    # Face
    draw.ellipse([420, 375, 435, 390], fill=(0, 0, 0))  # Left eye
    draw.ellipse([450, 375, 465, 390], fill=(0, 0, 0))  # Right eye
    draw.arc([425, 395, 460, 420], 0, 180, fill=(0, 0, 0), width=3)  # Smile
    
    # Add text
    draw.text((150, 200), "Контактный зоопарк", fill=(255, 255, 255))
    draw.text((180, 230), "с Нанобананом!", fill=(255, 223, 0))
    
    return img

def upload_to_s3(image, filename):
    """Upload image to MinIO S3"""
    s3 = boto3.client(
        's3',
        endpoint_url=S3_ENDPOINT,
        aws_access_key_id=S3_ACCESS_KEY,
        aws_secret_access_key=S3_SECRET_KEY,
        config=Config(signature_version='s3v4')
    )
    
    # Ensure bucket exists
    try:
        s3.head_bucket(Bucket=S3_BUCKET)
    except:
        s3.create_bucket(Bucket=S3_BUCKET)
    
    # Convert image to bytes
    img_bytes = io.BytesIO()
    image.save(img_bytes, format='JPEG', quality=85)
    img_bytes.seek(0)
    
    # Upload
    s3.upload_fileobj(
        img_bytes,
        S3_BUCKET,
        filename,
        ExtraArgs={'ContentType': 'image/jpeg', 'ACL': 'public-read'}
    )
    
    return f"{S3_PUBLIC_URL}/{filename}"

def update_database(cover_url):
    """Update tour cover_image in database"""
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()
    cur.execute("UPDATE tour SET cover_image = %s WHERE id = %s", (cover_url, TOUR_ID))
    conn.commit()
    conn.close()

def main():
    print("1. Creating zoo image with nanobanana...")
    img = create_zoo_image()
    
    print("2. Uploading to MinIO S3...")
    filename = f"tours/{TOUR_ID}/cover.jpg"
    public_url = upload_to_s3(img, filename)
    print(f"   Uploaded to: {public_url}")
    
    print("3. Updating database...")
    update_database(public_url)
    
    print("\nDone! Cover image updated.")
    print(f"URL: {public_url}")

if __name__ == "__main__":
    main()
