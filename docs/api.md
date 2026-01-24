# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Caching Strategy
*   **Public Endpoints**: `Cache-Control: public, max-age=60` + `ETag: W/"..."`.
*   **Behavior**: 60s client cache -> Conditional Request (304) -> Full Fetch.

## Endpoints

### Public
*   `GET /v1/public/cities`: List tenant cities.
*   `GET /v1/public/tours?city={slug}`: List tours (Published Only).
*   `GET /v1/public/catalog?city={slug}`: List POIs (Published Only).
*   `GET /v1/public/poi/{id}?city={slug}`: POI Detail (Published Only).
*   `GET /v1/public/map/attribution?city={slug}`: Map attribution.
*   `GET /v1/public/helpers`: List utility markers.

### Admin
(Requires `X-Admin-Token` header)
*   **Ingestion**: `enqueue` endpoints, `runs` inspection.
*   **Publishing**:
    *   `POST /pois`: Create Draft POI (Test Support).
    *   `POST /pois/{id}/publish`: Enforce gates (Sources + Licensed Media).
    *   `POST /pois/{id}/sources`: Add attribution.
    *   `POST /pois/{id}/media`: Add content.

### Internal
*   `POST /v1/internal/jobs/callback`: QStash webhook entrypoint.
