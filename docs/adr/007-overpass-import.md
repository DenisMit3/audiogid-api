# ADR-007: Overpass Import Strategy

## Context
We need to import POIs from OpenStreetMap for specific cities. Vercel Functions have strict hard timeouts:
*   **Hobby Plan**: 10 seconds (often too short for large Overpass queries).
*   **Pro Plan**: 60 seconds (better, but still finite).

Overpass API itself can be slow or rate-limited.

## Decision
*   **Query Strategy**: Use `map_to_area` derived from the Administrative Boundary Relation ID. This limits the search strictly to the city.
*   **Timeout Management**:
    *   **Overpass Server**: Query includes `[timeout:25]` to force the server to kill long queries faster than our client limit.
    *   **HTTP Client**: `httpx` is configured with `timeout=28.0` (connect=5) to handle network hangs or server slowness.
    *   **Platform Safety**: The client timeout (28s) MUST be comfortably below the Function limit (e.g., 60s). Note: On Hobby plan (10s limit), this will likely fail with a Platform Timeout before the client timeout triggers. In Production (Pro), it fits.
*   **Failure Mode**: 
    *   If a timeout occurs (Platform or Client), the Job is marked `FAILED` (if possible via exception catch) or remains `RUNNING` (stale) if hard-killed. 
    *   Stale jobs will be detected by future cleanup tasks (not in PR-3).
*   **Staging Upsert**:
    *   We write to `PoiStaging` using `city_slug` + `osm_id` as unique constraint.

## Consequences
*   Imports are atomic per-job.
*   Large cities (e.g. Moscow) will require tiling or a dedicated Long-Running Worker (e.g. ECS/Queue), as Serverless functions cannot handle minutes of processing.
