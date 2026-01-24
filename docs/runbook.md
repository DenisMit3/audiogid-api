# Audio Guide 2026 — Runbook

## Ops & Deployment
*   **Platform**: Vercel.
*   **Production URL**: Included in PR validation steps.
*   **Preview URL**: Generated per PR.

## CI/CD
*   **Linting**: strict eslint config.
*   **Tests**: GitHub Actions (planned).
*   **API Client**: Regenerated on every OpenAPI change.

## Environment Variables
(To be populated in Vercel Project Settings)
*   `DATABASE_URL`: Neon Postgres Connection String.
*   `BLOB_READ_WRITE_TOKEN`: Vercel Blob.
*   `QSTASH_TOKEN`: Upstash QStash.
*   `QSTASH_CURRENT_SIGNING_KEY`: QStash Verify.
*   `QSTASH_NEXT_SIGNING_KEY`: QStash Verify.
*   `PUBLIC_APP_BASE_URL`: Public Domain (e.g. api.mambax.app).

## Validation Procedures

### ETag / Caching Verification
(Requires curl or browser dev tools)
1.  **Initial Fetch**:
    `curl -i https://<host>/v1/public/cities`
    *Expect*: `200 OK`, `ETag: "..."`, body with cities.
2.  **Conditional Fetch**:
    `curl -i -H "If-None-Match: \"<etag_value>\"" https://<host>/v1/public/cities`
    *Expect*: `304 Not Modified`, empty body.

## Disaster Recovery
*   **Rollback**: Revert git commit + Vercel Instant Rollback.
