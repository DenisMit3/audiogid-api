#!/bin/bash
# Обновление конфигурации API для использования локального PostgreSQL
# Выполнять НА СЕРВЕРЕ Cloud.ru после импорта данных

set -e

API_DIR=/opt/audiogid/api
DB_URL="postgresql://audiogid:audiogid_secure_pass_2026@localhost:5432/audiogid"

echo "=== Updating API Configuration ==="

# Backup old .env
cp $API_DIR/.env $API_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)

# Update DATABASE_URL in .env
sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DB_URL|" $API_DIR/.env

echo "Updated DATABASE_URL in $API_DIR/.env"

# Restart API
echo "Restarting API service..."
sudo systemctl restart audiogid-api

# Wait and check
sleep 3
sudo systemctl status audiogid-api --no-pager

echo ""
echo "=== Configuration Updated ==="
echo "API should now use local PostgreSQL"
echo ""
echo "Test: curl http://localhost:8000/health"
