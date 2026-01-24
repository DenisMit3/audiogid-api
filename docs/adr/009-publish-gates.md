# ADR-009: Publish Gates & Licensing Compliance

## Context
We aggregate content from multiple sources (OSM, Wikipedia, manual). We must strictly respect licenses (CC BY-SA, ODbL). Publishing bare content without attribution is a legal risk.

## Decision
*   **Hard Gate**: A POI *cannot* be set to `published` (i.e. `published_at IS NOT NULL`) unless:
    1.  It has at least one associated `PoiSource` record (e.g., "OpenStreetMap" or "Wikipedia").
    2.  It has at least one associated `PoiMedia` record, AND that media record has valid `license_type`, `author`, and `source_page_url` fields.
*   **Audit Trail**: Every publish/unpublish action is logged to `audit_logs` with the actor (Admin Token) and timestamp.
*   **Visibility**: Public Catalog/Detail/Tour endpoints STRICTLY filter `WHERE published_at IS NOT NULL`.

## Consequences
*   Content ingestion (Stage 1) does not automatically result in live content. A secondary "enrichment & review" step (Stage 2/3) is required to add sources/media before Stage 4 (Publishing) can succeed.
*   If an Admin tries to bypass this, they receive a `422 Unprocessable Entity` error listing missing requirements.
