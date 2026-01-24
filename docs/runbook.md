# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel + Neon.
*   **Env**: `ADMIN_API_TOKEN` required.

## Validation Procedures

### Publishing Flow (Tours)
1.  **Create Draft Tour**:
    `POST /v1/admin/tours` -> Status Draft.
2.  **Add Item (Unpublished POI)**:
    `POST /v1/admin/tours/{ID}/items` with unpublished POI.
3.  **Try Publish (Fail)**:
    `POST /v1/admin/tours/{ID}/publish`
    *Expect*: 422 JSON Body:
    ```json
    {
      "error": "TOUR_PUBLISH_BLOCKED",
      "missing_requirements": ["sources", "media"],
      "unpublished_poi_ids": ["..."]
    }
    ```
4.  **Fix & Publish**: Match all gates -> 200 OK.

### Caching Check
1.  **Request Tour Detail**:
    `GET /v1/public/tours/{ID}?city=...`
    *Response*: 200 OK, Header `ETag: "..."`, `Cache-Control: public, max-age=60`.
2.  **Verify 304**:
    `GET /v1/public/tours/{ID}?city=...`
    Header `If-None-Match: "..."` (Insert ETag from step 1).
    *Response*: 304 Not Modified.

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
