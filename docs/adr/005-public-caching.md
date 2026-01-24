# ADR-005: Public API Caching Strategy

## Context
Mobile clients need to work offline-first. Downloading the entire catalog every launch is inefficient. We need a standard mechanism to tell the client "nothing changed".

## Decision
*   **Mechanism**: HTTP ETag + Conditional Requests.
*   **Implementation**:
    *   Server computes a strong ETag (SHA-256 hash) of the JSON serialization of the result set.
    *   Server checks `If-None-Match` header.
    *   If matches: Return `304 Not Modified` (body empty).
    *   If new: Return `200 OK` + `ETag` header + `Cache-Control: private, max-age=60`. (Short max-age allows frequent re-checks, relying on 304 for bandwidth saving).
*   **Scope**: All `GET /v1/public/*` endpoints.

## Consequences
*   **Bandwidth**: drastically reduced for repeating users.
*   **Compute**: Server still queries DB to compute hash (unless we implement higher-level cache, but DB query is cheap compared to payload transfer).
*   **Client**: Must store ETag and send `If-None-Match`.
