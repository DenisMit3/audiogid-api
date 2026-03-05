# Скрипт для тестирования облачного API
# Использование: .\scripts\test-cloud-api.ps1

$API_BASE = "http://82.202.159.64/v1"
$PASSED = 0
$FAILED = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Тестирование Backend API (Облако)" -ForegroundColor Cyan
Write-Host "API Base URL: $API_BASE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -ErrorAction Stop
        $status = $response.StatusCode
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "✓ $Name : OK (Status: $status)" -ForegroundColor Green
            $script:PASSED++
            return $true
        } else {
            Write-Host "✗ $Name : FAILED (Status: $status, Expected: $ExpectedStatus)" -ForegroundColor Red
            $script:FAILED++
            return $false
        }
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        Write-Host "✗ $Name : FAILED (Status: $status, Expected: $ExpectedStatus)" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        $script:FAILED++
        return $false
    }
}

function Test-EndpointWithContent {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -ErrorAction Stop
        $status = $response.StatusCode
        $content = $response.Content | ConvertFrom-Json
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "✓ $Name : OK (Status: $status)" -ForegroundColor Green
            if ($content -is [Array]) {
                Write-Host "  Найдено записей: $($content.Count)" -ForegroundColor Gray
            } elseif ($content.PSObject.Properties.Name -contains "pois") {
                $poiCount = if ($content.pois) { $content.pois.Count } else { 0 }
                $tourCount = if ($content.tours) { $content.tours.Count } else { 0 }
                Write-Host "  POI: $poiCount, Tours: $tourCount" -ForegroundColor Gray
            }
            $script:PASSED++
            return $true
        } else {
            Write-Host "✗ $Name : FAILED (Status: $status, Expected: $ExpectedStatus)" -ForegroundColor Red
            $script:FAILED++
            return $false
        }
    } catch {
        $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
        Write-Host "✗ $Name : FAILED (Status: $status, Expected: $ExpectedStatus)" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        $script:FAILED++
        return $false
    }
}

Write-Host "1. Проверка Health Check..." -ForegroundColor Yellow
Test-Endpoint "Health Check" "$API_BASE/ops/health"
Write-Host ""

Write-Host "2. Проверка OpenAPI Schema..." -ForegroundColor Yellow
Test-Endpoint "OpenAPI Schema" "$API_BASE/openapi.json"
Write-Host ""

Write-Host "3. Проверка публичных endpoints..." -ForegroundColor Yellow
Write-Host "   3.1. Получение списка городов..." -ForegroundColor Gray
Test-EndpointWithContent "Cities" "$API_BASE/public/cities"
Write-Host ""

Write-Host "   3.2. Получение каталога (kaliningrad_city)..." -ForegroundColor Gray
Test-EndpointWithContent "Catalog" "$API_BASE/public/catalog?city=kaliningrad_city"
Write-Host ""

Write-Host "   3.3. Получение списка туров..." -ForegroundColor Gray
Test-EndpointWithContent "Tours" "$API_BASE/public/tours?city=kaliningrad_city"
Write-Host ""

Write-Host "4. Проверка ETag кэширования..." -ForegroundColor Yellow
try {
    $firstResponse = Invoke-WebRequest -Uri "$API_BASE/public/catalog?city=kaliningrad_city" -Method Get -UseBasicParsing
    $etag = $firstResponse.Headers['ETag']
    
    if ($etag) {
        Write-Host "  ETag получен: $etag" -ForegroundColor Gray
        
        $headers = @{
            'If-None-Match' = $etag
        }
        $cachedResponse = Invoke-WebRequest -Uri "$API_BASE/public/catalog?city=kaliningrad_city" -Method Get -Headers $headers -UseBasicParsing -ErrorAction Stop
        
        if ($cachedResponse.StatusCode -eq 304) {
            Write-Host "✓ ETag кэширование работает (Status: 304)" -ForegroundColor Green
            $script:PASSED++
        } else {
            Write-Host "⚠ ETag кэширование не работает как ожидалось (Status: $($cachedResponse.StatusCode))" -ForegroundColor Yellow
            $script:FAILED++
        }
    } else {
        Write-Host "⚠ ETag заголовок не найден" -ForegroundColor Yellow
        $script:FAILED++
    }
} catch {
    Write-Host "⚠ Ошибка при проверке ETag: $($_.Exception.Message)" -ForegroundColor Yellow
    $script:FAILED++
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Результаты тестирования:" -ForegroundColor Cyan
Write-Host "Пройдено: $PASSED" -ForegroundColor Green
Write-Host "Провалено: $FAILED" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

if ($FAILED -eq 0) {
    Write-Host ""
    Write-Host "✓ Все тесты пройдены успешно!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "✗ Некоторые тесты провалены. Проверьте логи выше." -ForegroundColor Red
    exit 1
}

