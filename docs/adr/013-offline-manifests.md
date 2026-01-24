# ADR-013: Offline Manifests & Audio Gates

## Context
Users pay for Tours to use them offline. We need a way to securely deliver the full content package while ensuring "Audio Guide" quality standards.

## Decision
*   **Manifest Strategy**: A single `GET /tours/{id}/manifest` endpoint delivers all necessary metadata and asset URLs for a tour.
    *   **Gated**: Requires server-side `Entitlement` check. Returns 403 if unpaid.
    *   **Content**: Includes full POI details (with descriptions) and all Media URLs.
*   **Audio Quality Gate**: A Tour cannot be published until **every** constituent POI has at least one media item with `type='audio'`.
    *   *Mechanism*: `check_publish` logic in Admin API.
    *   *Exceptions*: None. It's an Audio Guide.

## Consequences
*   **Client**: Must implement robust downloading logic based on the `assets` list in the Manifest.
*   **Security**: Prevents unauthorized scraping of premium content via public API (which only returns Metadata/Locations).
*   **Data Model**: Added `description_ru` to POI to support text content in offline mode.
