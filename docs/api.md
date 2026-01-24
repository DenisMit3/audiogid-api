# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Authentication
*   **Public Read Endpoints**: No authentication required.
*   **Admin Endpoints**: Require `X-Admin-Token` header.

## Caching Strategy
*   **Public Endpoints**: `Cache-Control: public, max-age=60` + `ETag: W/"..."`.
*   **Behavior**: 60s client cache -> Conditional Request (304) -> Full Fetch.

## Endpoints (Summary)

### Public (Offline Onboarding)
*   `GET /v1/public/cities`: List available city tenants.
*   `GET /v1/public/tours?city={slug}`: List tours for a city.
*   `GET /v1/public/catalog?city={slug}`: List POIs for a city.

### Admin Ingestion
*   `POST /v1/admin/ingestion/osm/enqueue`: Import OSM Data.
    *   Auth: `X-Admin-Token`
    *   Body: `{city_slug, boundary_ref}`
*   `POST /v1/admin/ingestion/helpers/enqueue`: Import Helpers.
    *   Auth: `X-Admin-Token`

### Internal
*   `POST /v1/internal/jobs/callback`: QStash webhook entrypoint (Secured via Signature).
