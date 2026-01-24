# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Caching Strategy
*   **Public Endpoints**: `Cache-Control: public, max-age=60` + `ETag`.
*   **Nearby**: `Cache-Control: private, max-age=10`. No ETag.

## Endpoints

### Public
*   `GET /v1/public/nearby`: Discovery. Params: `city`, `lat`, `lon`, `radius_m`.
*   `GET /v1/public/cities`: List tenant cities.
*   `GET /v1/public/tours`: List tours (Published Only).
*   `GET /v1/public/catalog`: List POIs (Published Only).
*   `GET /v1/public/poi/{id}`: POI Detail (Published Only).
*   `GET /v1/public/map/attribution`: Map attribution.
*   `GET /v1/public/helpers`: List utility markers.

### Admin (Auth: X-Admin-Token)
*   **Ingestion**: `enqueue`, `runs`.
*   **Publishing**: `create`, `publish`, `sources`, `media`.

### Internal
*   `POST /v1/internal/jobs/callback`: QStash webhook.
