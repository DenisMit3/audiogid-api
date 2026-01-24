# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel.
*   **Production URL**: Included in PR validation steps.

## CI/CD
*   **API Client**: Regenerated on every OpenAPI change.

## Environment Variables
*   `DATABASE_URL`, `QSTASH_TOKEN`, `OVERPASS_API_URL`, `ADMIN_API_TOKEN`...

## Validation Procedures

### Ingestion: Helpers (Admin)
1.  **Enqueue**:
    `POST /v1/admin/ingestion/helpers/enqueue` (Auth: X-Admin-Token)
    Body: `{"city_slug": "kaliningrad_city"}`
    *Expect*: 202 Accepted.
2.  **Monitor**:
    `GET /v1/jobs/{job_id}` -> Wait for `COMPLETED`.
3.  **Inspect**:
    `GET /v1/public/helpers?city=kaliningrad_city&category=toilet`
    *Expect*: JSON List (non-empty if OSM has data).

### Map Attribution (Public)
1.  **Fetch**:
    `GET /v1/public/map/attribution?city=kaliningrad_city`
    *Expect*: 200 OK + `ETag`.
2.  **Conditional**:
    `GET ...` with `If-None-Match: <etag>`
    *Expect*: 304 Not Modified.

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
