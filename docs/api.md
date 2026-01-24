# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Caching Strategy
*   **Public Endpoints**: `Cache-Control: public, max-age=60` + `ETag: W/"..."`.
*   **Behavior**: 60s client cache -> Conditional Request (304) -> Full Fetch.

## Endpoints

### Public (Offline Onboarding & Map)
*   `GET /v1/public/cities`: List tenant cities.
*   `GET /v1/public/tours?city={slug}`: List tours.
*   `GET /v1/public/catalog?city={slug}`: List POIs.
*   `GET /v1/public/map/attribution?city={slug}`: Map attribution config & license info.
*   `GET /v1/public/helpers?city={slug}&category={type}`: List utility markers (lat/lon).

### Admin Ingestion
(Requires `X-Admin-Token` header)
*   `POST /v1/admin/ingestion/osm/enqueue`: Import OSM Data.
*   `POST /v1/admin/ingestion/helpers/enqueue`: Import Helpers.
*   `GET /v1/admin/ingestion/runs`: Inspect past job runs.

### Internal
*   `POST /v1/internal/jobs/callback`: QStash webhook entrypoint.
