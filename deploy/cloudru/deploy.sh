#!/bin/bash
# Deploy script for Audiogid API on Cloud.ru VM

set -e

APP_DIR=/opt/audiogid
API_DIR=$APP_DIR/api

echo "=== Deploying Audiogid API to Cloud.ru ==="

# Create directories
sudo mkdir -p $API_DIR
sudo chown -R user1:user1 $APP_DIR

# Copy API files
echo "Copying API files..."
cd $API_DIR

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --user -r requirements.txt

# Copy environment file
cp .env.cloudru .env

# Run migrations
echo "Running database migrations..."
cd $API_DIR
python3 -m alembic upgrade head

echo "=== Deployment complete ==="
echo "Start API with: uvicorn index:app --host 0.0.0.0 --port 8000"
