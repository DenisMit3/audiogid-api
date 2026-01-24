# PR TEMPLATE (USE LITERALLY)

PR Title: PR-5: Security & Compliance - Publish Gates

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement Server-Side Publish Gates (Sources + Licensed Media required) and Audit Logging.
C) Interfaces in play: Admin Publish API (`publish`, `unpublish`, `check`, `create`), Public Detail API (`/poi/{id}`).
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented strict publishing logic. Admin cannot publish a POI without >=1 Source and >=1 Licensed Media.
- **Security**: Audit Logging now uses `actor_fingerprint` (SHA256) instead of raw token. Secrets are never stored.
- **Testability**: Added `POST /pois` (Create Draft) to allow full cloud-only validation without DB access.
- **Public API**: Catalog/Tours/Detail endpoints strictly filter `WHERE published_at IS NOT NULL`.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-009 (Publish Gates), updated `docs/api.md` and `docs/runbook.md`.

Scope / Non-Goals
- **In Scope**: Publish Logic, Gates, Audit Logs, Public Visibility Filters, Cloud Validation Support.
- **Out of Scope**: Content ingestion (Stage 1 is Async), UI implementation, Payment.

Key Design Decisions
- **Hard Gate**: 422 Error if gates fail. 
- **Audit Fingerprinting**: SHA256 ensures traceability without leaking secrets.
- **Visibility**: Database-level filtering ensures unpublished content never leaks.

Docs Updated (docs-as-code)
- docs/api.md: Updated with Publish/Detail endpoints.
- docs/runbook.md: Updated with Cloud Validation Steps.
- docs/adr/009-publish-gates.md: Created.

Files Changed
- `apps/api/core/models.py`
- `apps/api/api/publish.py` (New)
- `apps/api/api/public.py` (Modified)
- `apps/api/api/index.py`
- `apps/api/migrations/versions/0004_pr5_gates.py` (New)
- `packages/contract/openapi.yaml`
- `docs/PR_5_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/009-publish-gates.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api` project.
- Env vars to add/update:
    - `ADMIN_API_TOKEN` (Required).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `POST /v1/admin/pois` -> Returns `id` (Create Draft).
    2.  `POST /v1/admin/pois/{id}/publish` -> Expect 422 (Gates Failed).
    3.  Add Sources/Media via Admin API.
    4.  `POST /v1/admin/pois/{id}/publish` -> Expect 200 OK.
    5.  `GET /v1/public/poi/{id}` -> Expect 200 JSON.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: New migration if schema issues.

Validation step
- URLs:
  - <Preview URL> /v1/admin/pois (for creating test data)
- Logs:
  - Vercel Logs: "Gates Failed" logs during test.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: done
- DB / migrations: done
- Security: done (Gates + Audit Fingerprint)
- Performance / caching: done
- Observability / ops: done
- Testing: n/a
- Mobile offline-first: done
- Publish gates: done
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: done
- Privacy / Data safety / deletion: n/a
- Docs-as-code: done
- No-local: done
