Write-Host "Verifying Firebase Setup..." -ForegroundColor Cyan

$androidParams = "apps/mobile_flutter/android/app/google-services.json"
$iosParams = "apps/mobile_flutter/ios/Runner/GoogleService-Info.plist"
$iosParamsAlt = "apps/mobile_flutter/ios/GoogleService-Info.plist"

if (Test-Path $androidParams) {
    Write-Host "✅ Android config found." -ForegroundColor Green
} else {
    Write-Host "❌ Android config MISSING at $androidParams" -ForegroundColor Red
}

if ((Test-Path $iosParams) -or (Test-Path $iosParamsAlt)) {
    Write-Host "✅ iOS config found." -ForegroundColor Green
} else {
    Write-Host "❌ iOS config MISSING at $iosParams (or root)" -ForegroundColor Red
}

$pubspec = Get-Content "apps/mobile_flutter/pubspec.yaml" -Raw
if ($pubspec -match "firebase_core") {
     Write-Host "✅ firebase_core dependency found." -ForegroundColor Green
}
if ($pubspec -match "firebase_crashlytics") {
     Write-Host "✅ firebase_crashlytics dependency found." -ForegroundColor Green
} else {
     Write-Host "❌ firebase_crashlytics dependency MISSING" -ForegroundColor Red
}

$main = Get-Content "apps/mobile_flutter/lib/main.dart" -Raw
if ($main -match "Firebase.initializeApp") {
     Write-Host "✅ Firebase initialized in main.dart." -ForegroundColor Green
}
if ($main -match "FirebaseCrashlytics.instance") {
     Write-Host "✅ Crashlytics initialized in main.dart." -ForegroundColor Green
} else {
     Write-Host "❌ Crashlytics initialization MISSING" -ForegroundColor Red
}

Write-Host "Verification Complete." -ForegroundColor Cyan
