$ErrorActionPreference = "Stop"

Write-Host "Setup GitHub Secrets via GH CLI"
Write-Host "Ensure you are logged in via 'gh auth login'"

$secrets = @{
    "VERCEL_TOKEN" = "Your Vercel Token"
    "DATABASE_URL" = "postgresql://user:pass@host/db"
    "JWT_SECRET" = "Generated Secret (e.g. openssl rand -base64 32)"
    "VERCEL_ORG_ID" = "Vercel Team ID"
    "VERCEL_PROJECT_ID" = "Vercel Project ID"
}

foreach ($key in $secrets.Keys) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "Setting $key..."
        # Interactive mode or simple check
        # gh secret set $key
        Write-Host "Run: gh secret set $key"
    } else {
        Write-Warning "GH CLI not found. Please add $key manually via GitHub Settings."
    }
}
