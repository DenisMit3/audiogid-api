#!/bin/bash
# Скрипт установки PostgreSQL и импорта данных на Cloud.ru
# Выполнять НА СЕРВЕРЕ Cloud.ru (82.202.159.64)

set -e

DB_NAME="audiogid"
DB_USER="audiogid"
DB_PASS="audiogid_secure_pass_2026"

echo "=== PostgreSQL Setup on Cloud.ru ==="

# 1. Установка PostgreSQL
echo "[1/5] Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# 2. Запуск PostgreSQL
echo "[2/5] Starting PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 3. Создание базы данных и пользователя
echo "[3/5] Creating database and user..."
sudo -u postgres psql << EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\c $DB_NAME
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOF

# 4. Настройка доступа
echo "[4/5] Configuring access..."
# Разрешаем подключения с localhost
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" /etc/postgresql/*/main/postgresql.conf

# Добавляем правило для локального подключения
echo "host    $DB_NAME    $DB_USER    127.0.0.1/32    md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf

sudo systemctl restart postgresql

# 5. Проверка
echo "[5/5] Verifying installation..."
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT version();"

echo ""
echo "=== PostgreSQL Ready ==="
echo "Connection string:"
echo "postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME"
echo ""
echo "Next step: Import data with import-data.sh"
