$ErrorActionPreference = "Stop"

$keystorePath = Join-Path (Get-Location) "apps\mobile_flutter\android\audiogid-release.jks"
$alias = "audiogid"
$validity = 10000

Write-Host "Checking for keytool..."
if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Warning "keytool command not found!"
    Write-Warning "Please install Java Development Kit (JDK) and ensure 'keytool' is in your PATH."
    Write-Warning "Download JDK: https://adoptium.net/"
    exit 1
}

if (Test-Path $keystorePath) {
    Write-Warning "Keystore already exists at: $keystorePath"
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -ne "y") { exit 0 }
    Remove-Item $keystorePath
}

Write-Host "Generating Release Keystore..."
Write-Host "You will be prompted for a password. Please remember it!"

& keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity $validity -alias $alias

if (Test-Path $keystorePath) {
    Write-Host "✅ Keystore generated successfully: $keystorePath"
    
    # Convert to Base64 for GitHub Secrets
    $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystorePath))
    Write-Host "`n[Action Required] Add this Base64 string to GitHub Secrets as ANDROID_KEYSTORE_BASE64:"
    Write-Host $base64
} else {
    Write-Error "Failed to generate keystore."
}
