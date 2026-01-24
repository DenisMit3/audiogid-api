# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel.
*   **Production URL**: Included in PR validation steps.

## Environment Variables
*   `ADMIN_API_TOKEN`: **REQUIRED** for all operations.

## Validation Procedures

### Publishing Flow (Cloud Validation)
1.  **Create Draft POI**:
    `POST /v1/admin/pois` (Auth Required)
    Body: `{"title_ru": "Cloud Test", "city_slug": "kaliningrad_city"}`
    *Response*: `{"id": "UUID", "status": "created_unpublished"}`. Copy UUID.

2.  **Try Publish (Fail)**:
    `POST /v1/admin/pois/{UUID}/publish` (Auth Required)
    *Expect*: 422 Unprocessable Entity (Gates Failed).

3.  **Add Source**:
    `POST /v1/admin/pois/{UUID}/sources`
    Body: `{"name": "OSM", "url": "https://osm.org"}`

4.  **Add Media**:
    `POST /v1/admin/pois/{UUID}/media`
    Body: `{"url": "https://example.com/img.jpg", "media_type": "image", "license_type": "CC-BY", "author": "WikiUser", "source_page_url": "https://example.com"}`

5.  **Publish (Success)**:
    `POST /v1/admin/pois/{UUID}/publish`
    *Expect*: 200 OK.

6.  **Verify Public**:
    `GET /v1/public/poi/{UUID}?city=kaliningrad_city`
    *Expect*: 200 OK (Visible).

## Disaster Recovery
*   **Rollback**: Revert + Instant Rollback.
