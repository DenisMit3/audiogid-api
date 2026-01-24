# IMPLEMENTATION PLAN — PR-4: Helpers Ingestion & Map Attribution

## 1. Schema & Constraints
*   **Helpers Table**: Ensure `HelperPlace` model (defined in PR-2) handles constraints strictly (`city_slug`, `osm_id`).
*   **Categories**: Define enum logic (toilets, water, cafe) in worker or model.

## 2. Async Worker Logic (Real Helpers Import)
*   **Handler**: Implement `_process_helpers_import` in `apps/api/core/worker.py`.
*   **Logic**:
    *   Construct Overpass QL for `node["amenity"~"toilets|drinking_water|cafe"](area.a)`.
    *   Execute call with `httpx` (timeout safety).
    *   Parse results (lat/lon, tags).
    *   **Upsert**: Check existing `osm_id`/`city_slug` in `HelperPlace`. Update attributes if needed.
    *   **Stats**: Write to `IngestionRun`.

## 3. Public Endpoints
*   **Map Attribution**: `GET /public/map/attribution`. Returns static config (MapLibre/OSM/OpenMapTiles requirements) based on city/tenant config if needed (or global default).
*   **Helpers List**: `GET /public/helpers`. Returns filtered list of helpers for the map overlay.
*   **Contract**: Update OpenAPI to include these.
*   **Caching**: Apply `check_etag` + `Cache-Control`.

## 4. Documentation
*   **ADR-008**: Helpers & Attribution Strategy.
*   **Runbook**: Validation steps for helpers job and attribution endpoint.

---

# Task Plan (PR-4)
1.  **Contract**: Add `GET /public/map/attribution` and `GET /public/helpers` to `openapi.yaml`.
2.  **API**: Implement `apps/api/api/map.py` (Attribution & Helpers).
3.  **Router**: Mount map router in `apps/api/api/index.py`.
4.  **Worker**: Implement `_process_helpers_import` in `apps/api/core/worker.py`.
5.  **Client**: Regenerate SDK.
6.  **Docs**: Create `docs/adr/008-helpers-attribution.md`, update `docs/runbook.md`.

---

# ADR-008: Helpers & Map Attribution

## Context
Visual map context is critical for tourists. "Helpers" (toilets, water, cafes) provide utility value. Additionally, license compliance for map data (OSM, OMT, MapLibre) requires strict attribution visibility.

## Decision
*   **Helpers Import**:
    *   Separate async job (Stage 1b) using Overpass.
    *   Filters: `amenity=toilets`, `amenity=drinking_water`, `amenity=cafe`.
    *   Storage: `helper_places` table (tenant-scoped).
*   **Map Attribution**:
    *   Dedicated endpoint `/public/map/attribution`.
    *   Returns structured JSON (not just HTML blob) to allow mobile clients to render standard native overlay or clickable link capability.
    *   **FAIL-SAFE**: If config missing, returns strict default OSM attribution.

## Consequences
*   Helpers are managed separately from core Content (Tours/POIs), preventing bloat in the main Catalog sync.
*   Attribution is centralized, allowing updates without App Store releases.
