#!/bin/bash
# =============================================================================
# Скрипт инициализации PostgreSQL + PostGIS на Cloud.ru
# Запускать на сервере 82.202.159.64 от root или с sudo
# =============================================================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# Конфигурация
# =============================================================================
DB_NAME="audiogid"
DB_USER="audiogid"
DB_PASSWORD="${DB_PASSWORD:-$(openssl rand -base64 16)}"
API_DIR="/opt/audiogid/api"

# =============================================================================
# 1. Установка PostgreSQL и PostGIS
# =============================================================================
install_postgresql() {
    log_info "Установка PostgreSQL и PostGIS..."
    
    apt update
    apt install -y postgresql postgresql-contrib postgis postgresql-14-postgis-3
    
    # Запуск и автозапуск
    systemctl enable postgresql
    systemctl start postgresql
    
    log_info "PostgreSQL установлен и запущен"
}

# =============================================================================
# 2. Создание базы данных и пользователя
# =============================================================================
create_database() {
    log_info "Создание базы данных и пользователя..."
    
    # Проверяем существует ли пользователь
    if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
        log_warn "Пользователь $DB_USER уже существует"
    else
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        log_info "Пользователь $DB_USER создан"
    fi
    
    # Проверяем существует ли БД
    if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
        log_warn "База данных $DB_NAME уже существует"
    else
        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        log_info "База данных $DB_NAME создана"
    fi
    
    # Права и расширения
    sudo -u postgres psql -d $DB_NAME << EOF
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
GRANT ALL ON SCHEMA public TO $DB_USER;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOF
    
    log_info "Расширения PostGIS и uuid-ossp установлены"
}

# =============================================================================
# 3. Настройка pg_hba.conf для локальных подключений
# =============================================================================
configure_access() {
    log_info "Настройка доступа..."
    
    PG_HBA="/etc/postgresql/14/main/pg_hba.conf"
    
    # Добавляем md5 аутентификацию для локальных подключений если еще нет
    if ! grep -q "host.*$DB_NAME.*$DB_USER.*127.0.0.1" "$PG_HBA"; then
        echo "host    $DB_NAME    $DB_USER    127.0.0.1/32    md5" >> "$PG_HBA"
        systemctl reload postgresql
        log_info "Добавлено правило доступа в pg_hba.conf"
    else
        log_warn "Правило доступа уже существует"
    fi
}

# =============================================================================
# 4. Запуск миграций Alembic
# =============================================================================
run_migrations() {
    log_info "Запуск миграций Alembic..."
    
    if [ ! -d "$API_DIR" ]; then
        log_error "Директория $API_DIR не найдена!"
        return 1
    fi
    
    cd "$API_DIR"
    
    # Устанавливаем DATABASE_URL
    export DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    
    # Активируем venv если есть
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    fi
    
    # Запускаем миграции
    python -m alembic upgrade head
    
    log_info "Миграции выполнены успешно"
}

# =============================================================================
# 5. Инициализация SKU (entitlements)
# =============================================================================
init_skus() {
    log_info "Инициализация SKU..."
    
    # Вызываем endpoint для создания entitlements
    curl -s -X POST "http://localhost:8000/ops/init-skus" || log_warn "API не запущен, SKU будут созданы позже"
}

# =============================================================================
# 6. Обновление .env файла
# =============================================================================
update_env() {
    log_info "Обновление .env файла..."
    
    ENV_FILE="$API_DIR/.env"
    NEW_DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    
    if [ -f "$ENV_FILE" ]; then
        # Заменяем DATABASE_URL
        if grep -q "^DATABASE_URL=" "$ENV_FILE"; then
            sed -i "s|^DATABASE_URL=.*|DATABASE_URL=$NEW_DATABASE_URL|" "$ENV_FILE"
        else
            echo "DATABASE_URL=$NEW_DATABASE_URL" >> "$ENV_FILE"
        fi
        log_info ".env обновлен"
    else
        log_warn ".env файл не найден, создаем новый"
        echo "DATABASE_URL=$NEW_DATABASE_URL" > "$ENV_FILE"
    fi
}

# =============================================================================
# 7. Вывод информации
# =============================================================================
print_summary() {
    echo ""
    echo "=============================================="
    echo -e "${GREEN}PostgreSQL успешно настроен!${NC}"
    echo "=============================================="
    echo ""
    echo "Параметры подключения:"
    echo "  Host:     localhost"
    echo "  Port:     5432"
    echo "  Database: $DB_NAME"
    echo "  User:     $DB_USER"
    echo "  Password: $DB_PASSWORD"
    echo ""
    echo "DATABASE_URL:"
    echo "  postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    echo ""
    echo "Следующие шаги:"
    echo "  1. Обновите .env файл с новым DATABASE_URL"
    echo "  2. Перезапустите API: systemctl restart audiogid-api"
    echo "  3. Запустите seed-data.py для заполнения данных"
    echo "  4. Вызовите /ops/init-skus для создания entitlements"
    echo ""
}

# =============================================================================
# Main
# =============================================================================
main() {
    log_info "Начало инициализации PostgreSQL на Cloud.ru"
    
    # Проверка root
    if [ "$EUID" -ne 0 ]; then
        log_error "Запустите скрипт от root: sudo ./init-db.sh"
        exit 1
    fi
    
    install_postgresql
    create_database
    configure_access
    update_env
    run_migrations
    init_skus
    print_summary
    
    log_info "Инициализация завершена!"
}

# Запуск
main "$@"
