Write-Host "Pulling Production Environment Variables..."
cmd /c "npx vercel env pull .env.prod.temp --environment=production --yes"

$keys = @("DATABASE_URL", "QSTASH_TOKEN", "QSTASH_CURRENT_SIGNING_KEY", "QSTASH_NEXT_SIGNING_KEY", "ADMIN_API_TOKEN")

if (Test-Path .env.prod.temp) {
    $content = Get-Content .env.prod.temp
    foreach ($k in $keys) {
        $line = $content | Where-Object { $_ -match "^$k=" }
        if ($line) {
            # Extract value. Remove Key= and surrounding quotes.
            # Handle possible single or double quotes wrapped around value by Vercel
            $val = $line -replace "^$k=", ""
            if ($val -match '^".*"$') { $val = $val.Substring(1, $val.Length-2) }
            elseif ($val -match "^'.*'$") { $val = $val.Substring(1, $val.Length-2) }
            
            Write-Host "Updating $k to Sensitive..."
            # Remove existing
            cmd /c "npx vercel env rm $k production --yes"
            # Add as sensitive (piping value)
            # Use cmd /c to ensure pipe works reliably with node/npx in some PS environments
            $val | npx vercel env add $k production --sensitive
        } else {
            Write-Host "WARNING: $k not found in .env.prod.temp"
        }
    }
    Remove-Item .env.prod.temp
} else {
    Write-Host "Failed to pull environment variables."
}
