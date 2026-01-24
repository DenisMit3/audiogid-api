# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel.
*   **Production URL**: Included in PR validation steps.
*   **Preview URL**: Generated per PR.

## CI/CD
*   **Linting**: strict eslint config.
*   **Tests**: GitHub Actions (planned).
*   **API Client**: Regenerated on every OpenAPI change.

## Environment Variables
*   `DATABASE_URL`: Neon Postgres.
*   `QSTASH_TOKEN`: Upstash.
*   `QSTASH_CURRENT_SIGNING_KEY`: Verify.
*   `PUBLIC_APP_BASE_URL`: Public Domain.
*   `OVERPASS_API_URL`: Configurable Overpass instance (Def: overpass-api.de).
*   `ADMIN_API_TOKEN`: Secret for Admin Ops.

## Validation Procedures

### Ingestion Triggers (Admin)
1.  **Enqueue**:
    `POST /v1/admin/ingestion/osm/enqueue` (Auth: X-Admin-Token: <SECRET>)
    Body: `{"city_slug": "kaliningrad_city", "boundary_ref": "319662"}` (Kaliningrad ID)
    *Expect*: 202 Accepted.
    
2.  **Monitor**:
    `GET /v1/jobs/{job_id}`
    *Expect*: `COMPLETED` (after ~10-20s). Result JSON matches `{"status": "success", "imported": N}`.
    
3.  **Inspect Runs**:
    `GET /v1/admin/ingestion/runs`
    *Expect*: JSON list with latest run stats.

## Disaster Recovery
*   **Rollback**: Revert git commit + Vercel Instant Rollback.
