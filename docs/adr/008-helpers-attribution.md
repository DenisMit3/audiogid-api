# ADR-008: Helpers Ingestion & Map Attribution

## Context
Visual map context is critical for tourists. "Helpers" (toilets, water, cafes) provide utility value. Additionally, license compliance for map data (OSM, OMT, MapLibre) requires strict attribution visibility.

## Decision
*   **Helpers Import (Stage 1b)**:
    *   Separate async job using Overpass.
    *   Filters: `amenity=toilets`, `amenity=drinking_water`, `amenity=cafe`.
    *   Storage: `helper_places` table (tenant-scoped).
    *   **Boundary Logic**: For Day 1, boundaries for key cities are hardcoded (`kaliningrad_city` -> 319662) to resolve `map_to_area`. Future expansion will move this to a DB config.
*   **Map Attribution**:
    *   Dedicated endpoint `/public/map/attribution`.
    *   Returns structured JSON (Text, URL, Provider) to support mobile-native overlays.
    *   **FAIL-SAFE**: Returns standard OpenStreetMap metrics by default.

## Consequences
*   Helpers are managed separately from core Content (Tours/POIs), avoiding catalog pollution.
*   Attribution is centralized and cacheable (`public, max-age=60`).
