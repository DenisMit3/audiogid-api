Write-Host "Creating PR 12 (Ingestion Pipeline)..."
# Assumes gh is authed or will prompt
gh pr create --base master --head feat/ingestion-v1 --title "feat(ingestion): osm import pipeline" --body "PR 12: Implements OSM Overpass Client, Staging Processor, and connects it to the Async Worker (Stage 1 Ingestion)."
