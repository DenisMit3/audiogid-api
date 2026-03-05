#!/bin/bash

# Скрипт для тестирования интеграции Backend API
# Использование: ./scripts/test-api-integration.sh [API_BASE_URL]

API_BASE="${1:-http://82.202.159.64/v1}"
# Если домен настроен, можно использовать: https://ckaud.ru/v1

echo "=========================================="
echo "Тестирование Backend API"
echo "API Base URL: $API_BASE"
echo "=========================================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для проверки ответа
check_response() {
    local name=$1
    local status=$2
    local expected=$3
    
    if [ "$status" -eq "$expected" ]; then
        echo -e "${GREEN}✓${NC} $name: OK (Status: $status)"
        return 0
    else
        echo -e "${RED}✗${NC} $name: FAILED (Status: $status, Expected: $expected)"
        return 1
    fi
}

# Счётчики
PASSED=0
FAILED=0

echo "1. Проверка Health Check..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/ops/health")
HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | tail -n1)
HEALTH_BODY=$(echo "$HEALTH_RESPONSE" | sed '$d')
if check_response "Health Check" "$HEALTH_STATUS" "200"; then
    echo "   Response: $HEALTH_BODY"
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

echo "2. Проверка OpenAPI Schema..."
OPENAPI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/openapi.json")
if check_response "OpenAPI Schema" "$OPENAPI_STATUS" "200"; then
    ((PASSED++))
else
    ((FAILED++))
fi
echo ""

echo "3. Проверка публичных endpoints..."

echo "   3.1. Получение списка городов..."
CITIES_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/public/cities")
CITIES_STATUS=$(echo "$CITIES_RESPONSE" | tail -n1)
CITIES_BODY=$(echo "$CITIES_RESPONSE" | sed '$d')
if check_response "Cities" "$CITIES_STATUS" "200"; then
    CITY_COUNT=$(echo "$CITIES_BODY" | grep -o '"slug"' | wc -l)
    echo "   Найдено городов: $CITY_COUNT"
    ((PASSED++))
else
    echo "   Response: $CITIES_BODY"
    ((FAILED++))
fi
echo ""

echo "   3.2. Получение каталога (kaliningrad_city)..."
CATALOG_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/public/catalog?city=kaliningrad_city")
CATALOG_STATUS=$(echo "$CATALOG_RESPONSE" | tail -n1)
CATALOG_BODY=$(echo "$CATALOG_RESPONSE" | sed '$d')
if check_response "Catalog" "$CATALOG_STATUS" "200"; then
    POI_COUNT=$(echo "$CATALOG_BODY" | grep -o '"id"' | wc -l)
    echo "   Найдено POI: $POI_COUNT"
    ((PASSED++))
else
    echo "   Response: $CATALOG_BODY"
    ((FAILED++))
fi
echo ""

echo "   3.3. Получение списка туров..."
TOURS_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_BASE/public/tours?city=kaliningrad_city")
TOURS_STATUS=$(echo "$TOURS_RESPONSE" | tail -n1)
TOURS_BODY=$(echo "$TOURS_RESPONSE" | sed '$d')
if check_response "Tours" "$TOURS_STATUS" "200"; then
    TOUR_COUNT=$(echo "$TOURS_BODY" | grep -o '"id"' | wc -l)
    echo "   Найдено туров: $TOUR_COUNT"
    ((PASSED++))
else
    echo "   Response: $TOURS_BODY"
    ((FAILED++))
fi
echo ""

echo "4. Проверка ETag кэширования..."
FIRST_REQUEST=$(curl -s -I "$API_BASE/public/catalog?city=kaliningrad_city" | grep -i "etag" | head -n1)
if [ -n "$FIRST_REQUEST" ]; then
    ETAG=$(echo "$FIRST_REQUEST" | cut -d' ' -f2 | tr -d '\r')
    echo "   ETag получен: $ETAG"
    
    # Второй запрос с If-None-Match
    CACHED_RESPONSE=$(curl -s -w "\n%{http_code}" -H "If-None-Match: $ETAG" "$API_BASE/public/catalog?city=kaliningrad_city")
    CACHED_STATUS=$(echo "$CACHED_RESPONSE" | tail -n1)
    if [ "$CACHED_STATUS" -eq "304" ]; then
        echo -e "${GREEN}✓${NC} ETag кэширование работает (Status: 304)"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} ETag кэширование не работает как ожидалось (Status: $CACHED_STATUS)"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠${NC} ETag заголовок не найден"
    ((FAILED++))
fi
echo ""

echo "5. Проверка CORS (если применимо)..."
CORS_HEADERS=$(curl -s -I -X OPTIONS "$API_BASE/public/cities" | grep -i "access-control")
if [ -n "$CORS_HEADERS" ]; then
    echo "   CORS заголовки найдены"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠${NC} CORS заголовки не найдены (может быть нормально для мобильного приложения)"
fi
echo ""

echo "=========================================="
echo "Результаты тестирования:"
echo -e "${GREEN}Пройдено: $PASSED${NC}"
echo -e "${RED}Провалено: $FAILED${NC}"
echo "=========================================="

if [ $FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

