# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Authentication
*   **Public Read Endpoints**: No authentication required.
*   **Admin/Write Endpoints**: (Planned) Authenticated.

## Caching Strategy
*   **Public Endpoints**: Support `If-None-Match` / `ETag`.
*   **Header Policy**:
    *   `Cache-Control: public, max-age=60`: Responses are cached by browsers/CDNs for 60 seconds.
    *   `ETag: W/"..."`: Weak ETag based on content hash + query context.
*   **Behavior**:
    *   First request: `200 OK` + Headers.
    *   Subsequent (within 60s): Served from cache (client side).
    *   Subsequent (after 60s): Client sends `If-None-Match`.
    *   Server: Returns `304 Not Modified` if data matches (saving bandwidth).

## Endpoints (Summary)

### Public (Offline Onboarding)
*   `GET /v1/public/cities`: List available city tenants.
*   `GET /v1/public/tours?city={slug}`: List tours for a city.
*   `GET /v1/public/catalog?city={slug}`: List POIs for a city.

### Internal
*   `POST /v1/internal/jobs/callback`: QStash webhook entrypoint.
