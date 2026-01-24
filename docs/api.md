# API Documentation

## Overview
*   **Protocol**: REST / OpenAPI 3.1.
*   **Base URL**: `/api/v1`

## Caching Strategy
*   **Tours List/Detail**: `Cache-Control: public, max-age=60`. Supports ETag / 304.
*   **POI List/Detail**: `Cache-Control: public, max-age=60`. Supports ETag / 304.
*   **Nearby**: `Cache-Control: private, max-age=10`.

## Error Handling
*   **422 Unprocessable Entity (Publish Gates)**:
    Structure:
    ```json
    {
      "error": "TOUR_PUBLISH_BLOCKED",
      "message": "Gates Failed",
      "missing_requirements": ["sources", "media"],
      "unpublished_poi_ids": ["uuid-1"]
    }
    ```

## Endpoints

### Public (Published Only)
*   `GET /tours`: List. Filter by `city`.
*   `GET /tours/{id}`: Detail. Includes Items, Sources, Media.
*   `GET /nearby`: Geo discovery.
*   `GET /catalog`: POI List.
*   `GET /poi/{id}`: POI Detail.

### Admin (Auth: X-Admin-Token)
*   **Tours**:
    *   `POST /admin/tours`: Create Draft.
    *   `POST /admin/tours/{id}/items`: Add POI.
    *   `POST /admin/tours/{id}/publish`: Strict Gates.
*   **POIs**: Create, Publish (with gates).
*   **Ingestion**: Import OSM/Helpers.
