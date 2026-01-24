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
*   `OVERPASS_API_URL`: (Optional) Custom Overpass instance for ingest.

## Validation Procedures

### ETag / Caching Verification
(See PR-1 section)

### Ingestion Triggers
(Requires Admin Auth in future; currently open)
1.  **Enqueue`:
    `POST /v1/admin/ingestion/osm/enqueue`
    Body: `{"city_slug": "kaliningrad_city", "boundary_ref": "relation/12345"}`
    *Expect*: `202 Accepted` + `job_id`.
2.  **Monitor**:
    `GET /v1/jobs/{job_id}`
    *Expect*: `PENDING` -> `RUNNING` -> `COMPLETED`.
    
## Disaster Recovery
*   **Rollback**: Revert git commit + Vercel Instant Rollback.
