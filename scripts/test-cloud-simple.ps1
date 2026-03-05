# Простой скрипт для тестирования облачного API
$API_BASE = "http://82.202.159.64/v1"
$PASSED = 0
$FAILED = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Тестирование Backend API (Облако)" -ForegroundColor Cyan
Write-Host "API Base URL: $API_BASE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Тест 1: Health Check
Write-Host "1. Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/ops/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $json = $response.Content | ConvertFrom-Json
        Write-Host "   OK - Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "   Response: $($json | ConvertTo-Json -Compress)" -ForegroundColor Gray
        $PASSED++
    } else {
        Write-Host "   FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
        $FAILED++
    }
} catch {
    Write-Host "   FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
    $FAILED++
}
Write-Host ""

# Тест 2: Cities
Write-Host "2. Получение списка городов..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/public/cities" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $cities = $response.Content | ConvertFrom-Json
        $count = if ($cities -is [Array]) { $cities.Count } else { 0 }
        Write-Host "   OK - Status: $($response.StatusCode), Найдено городов: $count" -ForegroundColor Green
        if ($count -gt 0) {
            $firstCity = $cities[0]
            Write-Host "   Первый город: $($firstCity.name_ru) ($($firstCity.slug))" -ForegroundColor Gray
        }
        $PASSED++
    } else {
        Write-Host "   FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
        $FAILED++
    }
} catch {
    Write-Host "   FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
    $FAILED++
}
Write-Host ""

# Тест 3: Catalog
Write-Host "3. Получение каталога (kaliningrad_city)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/public/catalog?city=kaliningrad_city" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $catalog = $response.Content | ConvertFrom-Json
        Write-Host "   OK - Status: $($response.StatusCode)" -ForegroundColor Green
        if ($catalog.pois) { Write-Host "   POI: $($catalog.pois.Count)" -ForegroundColor Gray }
        if ($catalog.tours) { Write-Host "   Tours: $($catalog.tours.Count)" -ForegroundColor Gray }
        $PASSED++
    } else {
        Write-Host "   FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
        $FAILED++
    }
} catch {
    Write-Host "   FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
    $FAILED++
}
Write-Host ""

# Тест 4: OpenAPI Schema (без /v1 префикса)
Write-Host "4. Проверка OpenAPI Schema..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://82.202.159.64/openapi.json" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $openapi = $response.Content | ConvertFrom-Json
        Write-Host "   OK - Status: $($response.StatusCode)" -ForegroundColor Green
        if ($openapi.info) {
            Write-Host "   Title: $($openapi.info.title)" -ForegroundColor Gray
            Write-Host "   Version: $($openapi.info.version)" -ForegroundColor Gray
        }
        $PASSED++
    } else {
        Write-Host "   FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
        $FAILED++
    }
} catch {
    Write-Host "   FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
    $FAILED++
}
Write-Host ""

# Тест 5: Проверка структуры каталога
Write-Host "5. Детальная проверка каталога..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/public/catalog?city=kaliningrad_city" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $catalog = $response.Content | ConvertFrom-Json
        Write-Host "   OK - Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "   Тип данных: $($catalog.GetType().Name)" -ForegroundColor Gray
        if ($catalog -is [Array]) {
            Write-Host "   Количество элементов: $($catalog.Count)" -ForegroundColor Gray
            if ($catalog.Count -gt 0) {
                $first = $catalog[0]
                Write-Host "   Первый элемент: $($first | ConvertTo-Json -Compress)" -ForegroundColor Gray
            }
        } elseif ($catalog.PSObject.Properties.Name) {
            $props = $catalog.PSObject.Properties.Name -join ", "
            Write-Host "   Свойства: $props" -ForegroundColor Gray
        }
        $PASSED++
    } else {
        Write-Host "   FAILED - Status: $($response.StatusCode)" -ForegroundColor Red
        $FAILED++
    }
} catch {
    Write-Host "   FAILED - Error: $($_.Exception.Message)" -ForegroundColor Red
    $FAILED++
}
Write-Host ""

# Итоги
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Результаты:" -ForegroundColor Cyan
Write-Host "Пройдено: $PASSED" -ForegroundColor Green
Write-Host "Провалено: $FAILED" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

if ($FAILED -eq 0) {
    Write-Host ""
    Write-Host "Все тесты пройдены!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "Некоторые тесты провалены." -ForegroundColor Red
    exit 1
}

