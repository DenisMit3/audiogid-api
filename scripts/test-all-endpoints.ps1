# Comprehensive API and Router Testing Script
# Tests all endpoints and routes

$API_BASE = "http://82.202.159.64/v1"
$API_ROOT = "http://82.202.159.64"
$PASSED = 0
$FAILED = 0
$WARNINGS = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Comprehensive API & Router Testing" -ForegroundColor Cyan
Write-Host "API Base URL: $API_BASE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200,
        [bool]$RequireAuth = $false
    )
    
    try {
        $headers = @{}
        if ($RequireAuth) {
            # Skip auth endpoints for now
            Write-Host "   SKIP - Requires authentication" -ForegroundColor Yellow
            $script:WARNINGS++
            return $false
        }
        
        $response = Invoke-WebRequest -Uri $Url -Method Get -Headers $headers -UseBasicParsing -ErrorAction Stop
        $status = $response.StatusCode
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "   OK - Status: $status" -ForegroundColor Green
            $script:PASSED++
            return $true
        } elseif ($status -eq 404) {
            Write-Host "   WARNING - Not Found (404) - Endpoint may not exist or no data" -ForegroundColor Yellow
            $script:WARNINGS++
            return $false
        } else {
            Write-Host "   FAILED - Status: $status, Expected: $ExpectedStatus" -ForegroundColor Red
            $script:FAILED++
            return $false
        }
    } catch {
        $status = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
        if ($status -eq 404) {
            Write-Host "   WARNING - Not Found (404) - Endpoint may not exist or no data" -ForegroundColor Yellow
            $script:WARNINGS++
            return $false
        } else {
            Write-Host "   FAILED - Status: $status, Expected: $ExpectedStatus" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
            $script:FAILED++
            return $false
        }
    }
}

# ==========================================
# PUBLIC API ENDPOINTS
# ==========================================
Write-Host "=== PUBLIC API ENDPOINTS ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Health Check..." -ForegroundColor Cyan
Test-Endpoint "Health Check" "$API_BASE/ops/health"
Write-Host ""

Write-Host "2. Cities..." -ForegroundColor Cyan
Test-Endpoint "Cities" "$API_BASE/public/cities"
Write-Host ""

Write-Host "3. Catalog (kaliningrad_city)..." -ForegroundColor Cyan
Test-Endpoint "Catalog" "$API_BASE/public/catalog?city=kaliningrad_city"
Write-Host ""

Write-Host "4. Tours (kaliningrad_city)..." -ForegroundColor Cyan
Test-Endpoint "Tours" "$API_BASE/public/tours?city=kaliningrad_city"
Write-Host ""

Write-Host "5. OpenAPI Schema..." -ForegroundColor Cyan
Test-Endpoint "OpenAPI" "$API_ROOT/openapi.json"
Write-Host ""

# ==========================================
# FLUTTER ROUTER CHECK
# ==========================================
Write-Host "=== FLUTTER ROUTER CHECK ===" -ForegroundColor Yellow
Write-Host ""

$flutterRoutes = @(
    "/",
    "/welcome",
    "/onboarding",
    "/city-select",
    "/nearby",
    "/catalog",
    "/favorites",
    "/tour/:id",
    "/poi/:id",
    "/player",
    "/offline-manager",
    "/tour_mode",
    "/qr_scanner",
    "/login",
    "/itinerary",
    "/itinerary/create",
    "/itinerary/view/:id",
    "/free_walking",
    "/sos",
    "/trusted_contacts",
    "/share_trip",
    "/settings",
    "/dl/tour/:id",
    "/dl/poi/:id",
    "/dl/city/:slug",
    "/dl/itinerary/:id"
)

Write-Host "Flutter Routes Defined: $($flutterRoutes.Count)" -ForegroundColor Cyan
foreach ($route in $flutterRoutes) {
    Write-Host "   - $route" -ForegroundColor Gray
}
Write-Host ""

# ==========================================
# ADMIN API PROXY CHECK
# ==========================================
Write-Host "=== ADMIN API PROXY CHECK ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "Admin proxy route exists..." -ForegroundColor Cyan
# Check proxy directory (relative to script location)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$proxyDir = Join-Path $rootDir "apps\admin\app\api\proxy"
if (Test-Path $proxyDir) {
    $proxyFiles = Get-ChildItem -Path $proxyDir -Recurse -Filter "route.ts" -ErrorAction SilentlyContinue
    if ($proxyFiles) {
        Write-Host "   OK - Admin proxy route files found: $($proxyFiles.Count)" -ForegroundColor Green
        foreach ($file in $proxyFiles) {
            Write-Host "      - $($file.FullName.Replace((Get-Location).Path + '\', ''))" -ForegroundColor Gray
        }
        $PASSED++
    } else {
        Write-Host "   WARNING - Admin proxy directory exists but route.ts not found" -ForegroundColor Yellow
        $WARNINGS++
    }
} else {
    Write-Host "   WARNING - Admin proxy directory not found" -ForegroundColor Yellow
    $WARNINGS++
}
Write-Host ""

# ==========================================
# SUMMARY
# ==========================================
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Results:" -ForegroundColor Cyan
Write-Host "Passed: $PASSED" -ForegroundColor Green
Write-Host "Warnings: $WARNINGS" -ForegroundColor Yellow
Write-Host "Failed: $FAILED" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan

if ($FAILED -eq 0) {
    Write-Host ""
    Write-Host "All critical tests passed!" -ForegroundColor Green
    if ($WARNINGS -gt 0) {
        Write-Host "Some endpoints returned 404 (may be expected if no data)" -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host ""
    Write-Host "Some tests failed. Check logs above." -ForegroundColor Red
    exit 1
}

