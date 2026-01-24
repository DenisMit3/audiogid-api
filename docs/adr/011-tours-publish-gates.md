# ADR-011: Tours Publish Gates

## Context
Tours are premium content products aggregating multiple POIs. We must prevent broken user experiences (e.g., tours containing 404 POIs) and ensure strict licensing compliance for the tour container itself (cover image, description source).

## Decision
*   **Gate 1: Attribution**: A Tour cannot be published without:
    *   At least 1 Source.
    *   At least 1 Media item with valid license/author/source_url.
*   **Gate 2: Consistency (Recursive Gate)**: A Tour cannot be published if **ANY** of its linked POIs are not published (`published_at IS NULL`).
    *   *Mechanism*: Check `TourItem` -> `Poi.published_at` during the Publish transaction.
*   **Audit**: All Tour publish/unpublish actions are logged in `audit_logs` with actor fingerprint.

## Consequences
*   Publishing a Tour is a multi-step dependency chain. Admin must Fix -> Publish POIs -> Create Tour -> Publish Tour.
*   Ensures Public API never serves "broken" tours with missing stops.
