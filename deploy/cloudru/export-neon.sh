#!/bin/bash
# Скрипт миграции с Neon на локальный PostgreSQL на Cloud.ru

# === ЧАСТЬ 1: Экспорт из Neon (выполнить локально) ===

# Neon credentials
NEON_HOST="ep-restless-pond-af40wky4.c-2.us-west-2.aws.neon.tech"
NEON_DB="neondb"
NEON_USER="neondb_owner"
NEON_PASS="npg_mRMN7C3ohGHz"

# Экспорт данных
echo "Exporting data from Neon..."
PGPASSWORD=$NEON_PASS pg_dump \
    -h $NEON_HOST \
    -U $NEON_USER \
    -d $NEON_DB \
    --no-owner \
    --no-privileges \
    -F c \
    -f neon_backup.dump

echo "Backup saved to neon_backup.dump"
echo "Size: $(ls -lh neon_backup.dump | awk '{print $5}')"
