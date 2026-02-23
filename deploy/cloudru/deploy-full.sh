#!/bin/bash
# Full deploy script for Audiogid on Cloud.ru VM (82.202.159.64)
# Run this script ON THE SERVER after copying files

set -e

APP_DIR=/opt/audiogid
API_DIR=$APP_DIR/api
ADMIN_DIR=$APP_DIR/admin

echo "=== Audiogid Full Deploy ==="

# 1. Create directories
echo "[1/7] Creating directories..."
sudo mkdir -p $API_DIR $ADMIN_DIR
sudo chown -R $USER:$USER $APP_DIR

# 2. Setup API environment
echo "[2/7] Setting up API environment..."
cat > $API_DIR/.env << 'EOF'
DATABASE_URL=postgresql://neondb_owner:npg_mRMN7C3ohGHz@ep-restless-pond-af40wky4-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require
JWT_SECRET=very-secure-jwt-secret-for-audiogid-2026-gen-by-agent-v1
JWT_ALGORITHM=HS256
ADMIN_API_TOKEN=temp-admin-key-2026
OTP_TTL_SECONDS=300
TELEGRAM_BOT_TOKEN=8346337210:AAFbeka9ot5aBpwbPl-3ggD6on37pQ2tAoM
DEPLOY_ENV=production
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=audiogid
S3_PUBLIC_URL=http://82.202.159.64:9000/audiogid
PUBLIC_URL=http://82.202.159.64:8000
EOF

# 3. Install Python dependencies
echo "[3/7] Installing Python dependencies..."
cd $API_DIR
pip3 install --user -r requirements.txt

# 4. Setup Admin environment
echo "[4/7] Setting up Admin environment..."
cat > $ADMIN_DIR/.env << 'EOF'
NEXT_PUBLIC_API_URL=http://82.202.159.64:8000
BACKEND_URL=http://82.202.159.64:8000
DEPLOY_ENV=production
EOF

# 5. Install Node dependencies and build admin
echo "[5/7] Building Admin panel..."
cd $ADMIN_DIR
npm install -g pnpm
pnpm install
pnpm build

# 6. Setup systemd services
echo "[6/7] Setting up systemd services..."

# API Service
sudo tee /etc/systemd/system/audiogid-api.service > /dev/null << 'EOF'
[Unit]
Description=Audiogid API Service
After=network.target

[Service]
Type=simple
User=user1
Group=user1
WorkingDirectory=/opt/audiogid/api
EnvironmentFile=/opt/audiogid/api/.env
ExecStart=/home/user1/.local/bin/uvicorn index:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Admin Service
sudo tee /etc/systemd/system/audiogid-admin.service > /dev/null << 'EOF'
[Unit]
Description=Audiogid Admin Panel
After=network.target

[Service]
Type=simple
User=user1
Group=user1
WorkingDirectory=/opt/audiogid/admin
EnvironmentFile=/opt/audiogid/admin/.env
ExecStart=/usr/bin/npx next start -p 3080
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 7. Start services
echo "[7/7] Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable audiogid-api audiogid-admin
sudo systemctl restart audiogid-api audiogid-admin

echo ""
echo "=== Deploy Complete ==="
echo "API:   http://82.202.159.64:8000"
echo "Admin: http://82.202.159.64:3080"
echo ""
echo "Check status:"
echo "  sudo systemctl status audiogid-api"
echo "  sudo systemctl status audiogid-admin"
