# ADR-010: Geospatial Strategy (PostGIS Geography)

## Context
Mobile users need "Nearby" discovery to find POIs and Helpers suitable for walking distance.

## Decision
*   **Engine**: PostGIS (Neon/Vercel compliant via `CREATE EXTENSION IF NOT EXISTS postgis`).
*   **Type**: `geography(Point, 4326)`.
    *   *Why?*: Native calculation in **Meters** (not degrees) without complex projection handling (SRID 3857 vs 4326 casts).
*   **Storage**: 
    *   `geo`: geography column for indexes and distance calculations.
    *   `lat`/`lon`: float columns for IO and edits.
*   **Indexing**: `GiST` index on `geo`.
*   **Queries**: `ST_DWithin` and `ST_Distance` on geography columns using meters limits.

## Consequences
*   Requires PostGIS extension.
*   Simplifies distance logic (no Haversine implementation in app).
*   Correctly handles earth curvature for larger distances compared to basic lat/lon euclidean math (though less relevant for 5km radius, better for correctness).
