# Cloud API Testing Script
# Tests cloud API endpoints (ckaud.ru / 82.202.159.64)

$API_BASE = "http://82.202.159.64/v1"
$API_ROOT = "http://82.202.159.64"
$PASSED = 0
$FAILED = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Cloud API Testing" -ForegroundColor Cyan
Write-Host "API Base URL: $API_BASE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
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

# Test 2: Cities
Write-Host "2. Get Cities List..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/public/cities" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $cities = $response.Content | ConvertFrom-Json
        $count = if ($cities -is [Array]) { $cities.Count } else { 0 }
        Write-Host "   OK - Status: $($response.StatusCode), Cities found: $count" -ForegroundColor Green
        if ($count -gt 0) {
            $firstCity = $cities[0]
            Write-Host "   First city: $($firstCity.name_ru) ($($firstCity.slug))" -ForegroundColor Gray
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

# Test 3: Catalog
Write-Host "3. Get Catalog (kaliningrad_city)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_BASE/public/catalog?city=kaliningrad_city" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $catalog = $response.Content | ConvertFrom-Json
        Write-Host "   OK - Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "   Data type: $($catalog.GetType().Name)" -ForegroundColor Gray
        if ($catalog -is [Array]) {
            Write-Host "   Items count: $($catalog.Count)" -ForegroundColor Gray
            if ($catalog.Count -gt 0) {
                $first = $catalog[0]
                Write-Host "   First item keys: $($first.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
            }
        } elseif ($catalog.PSObject.Properties.Name) {
            $props = $catalog.PSObject.Properties.Name -join ", "
            Write-Host "   Properties: $props" -ForegroundColor Gray
            foreach ($prop in $catalog.PSObject.Properties.Name) {
                $value = $catalog.$prop
                if ($value -is [Array]) {
                    Write-Host "   $prop : Array with $($value.Count) items" -ForegroundColor Gray
                }
            }
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

# Test 4: OpenAPI Schema
Write-Host "4. Check OpenAPI Schema..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_ROOT/openapi.json" -UseBasicParsing
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

# Test 5: ETag Caching
Write-Host "5. Check ETag Caching..." -ForegroundColor Yellow
try {
    $firstResponse = Invoke-WebRequest -Uri "$API_BASE/public/cities" -UseBasicParsing
    $etag = $firstResponse.Headers['ETag']
    
    if ($etag) {
        Write-Host "   ETag received: $etag" -ForegroundColor Gray
        
        $headers = @{
            'If-None-Match' = $etag
        }
        try {
            $cachedResponse = Invoke-WebRequest -Uri "$API_BASE/public/cities" -Method Get -Headers $headers -UseBasicParsing -ErrorAction Stop
            
            if ($cachedResponse.StatusCode -eq 304) {
                Write-Host "   OK - ETag caching works (Status: 304)" -ForegroundColor Green
                $PASSED++
            } else {
                Write-Host "   WARNING - ETag caching not working as expected (Status: $($cachedResponse.StatusCode))" -ForegroundColor Yellow
                $FAILED++
            }
        } catch {
            $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
            if ($status -eq 304) {
                Write-Host "   OK - ETag caching works (Status: 304)" -ForegroundColor Green
                $PASSED++
            } else {
                Write-Host "   WARNING - ETag caching issue (Status: $status)" -ForegroundColor Yellow
                $FAILED++
            }
        }
    } else {
        Write-Host "   WARNING - ETag header not found" -ForegroundColor Yellow
        $FAILED++
    }
} catch {
    Write-Host "   WARNING - Error checking ETag: $($_.Exception.Message)" -ForegroundColor Yellow
    $FAILED++
}
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Results:" -ForegroundColor Cyan
Write-Host "Passed: $PASSED" -ForegroundColor Green
Write-Host "Failed: $FAILED" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

if ($FAILED -eq 0) {
    Write-Host ""
    Write-Host "All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "Some tests failed. Check logs above." -ForegroundColor Red
    exit 1
}

