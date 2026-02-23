#!/bin/bash
# Скрипт импорта данных из Neon backup
# Выполнять НА СЕРВЕРЕ Cloud.ru после setup-postgres.sh

set -e

DB_NAME="audiogid"
DB_USER="audiogid"
DB_PASS="audiogid_secure_pass_2026"
BACKUP_FILE="neon_backup.dump"

echo "=== Importing Data from Neon Backup ==="

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    echo "Please copy neon_backup.dump to this directory first"
    exit 1
fi

# Импорт данных
echo "Importing data..."
PGPASSWORD=$DB_PASS pg_restore \
    -h localhost \
    -U $DB_USER \
    -d $DB_NAME \
    --no-owner \
    --no-privileges \
    --clean \
    --if-exists \
    $BACKUP_FILE || true  # Игнорируем ошибки "already exists"

# Проверка
echo ""
echo "Verifying import..."
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME << EOF
SELECT 'Tours:' as table_name, COUNT(*) as count FROM tour
UNION ALL
SELECT 'POIs:', COUNT(*) FROM poi
UNION ALL
SELECT 'Users:', COUNT(*) FROM users;
EOF

echo ""
echo "=== Import Complete ==="
