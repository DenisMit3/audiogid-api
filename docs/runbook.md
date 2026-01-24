# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel + Neon Postgres.
*   **Extensions**: PostGIS MUST be enabled on the DB.
*   **Environment**: `ADMIN_API_TOKEN` required.

## Validation Procedures

### Nearby Discovery (PostGIS)
1.  **Check Extension**:
    Query DB: `SELECT postgis_version();` -> Should return version.

2.  **Query**:
    `GET /v1/public/nearby?city=kaliningrad_city&lat=54.71&lon=20.50&radius_m=2000`
    *Expect*: 200 OK. Records sorted by `distance_m`.

3.  **Logs**:
    Check Vercel Logs. Look for "Nearby Query" entry. Ensure `lat`/`lon` keys are MISSING (Redacted).

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
