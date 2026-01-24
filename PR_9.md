# PR TEMPLATE (USE LITERALLY)

PR Title: PR-9: Secure Content Delivery (Manifests & Audio Gates)

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Implement 'Offline-First' content delivery via secured Manifests and enforce Audio quality.
C) Interfaces in play: `GET /tours/{id}/manifest`.
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Added `get_tour_manifest` endpoint. Aggregates all Tour & POI assets into a single downloadable list.
- **Security**: Manifest is **Gated** by `Entitlement`. Returns 403 if `device_anon_id` has not purchased the tour.
- **Quality**: Updated `admin_tours.py` to BLOCK publishing if any POI lacks `media_type='audio'`.
- **Schema**: Added `description_ru` to `Poi`.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-013, updated docs.

Scope / Non-Goals
- **In Scope**: Secure Download, Audio Quality Enforcement, POI Description.
- **Out of Scope**: Binary file hosting (we assume URLs are provided via admin).

Key Design Decisions
- **Manifest vs Detail**: `Detail` is the Public Store Page. `Manifest` is the Product.
- **Audio Mandate**: Enforced at Publish time to ensure "Audio Guide" connects to its name.

Docs Updated (docs-as-code)
- docs/api.md: Updated with Manifest endpoint.
- docs/runbook.md: Added Manifest validation steps.
- docs/adr/013-offline-manifests.md: Created.

Files Changed
- `apps/api/core/models.py`
- `apps/api/api/public.py`
- `apps/api/api/admin_tours.py`
- `apps/api/migrations/versions/0008_pr9_poi_desc.py` (New)
- `packages/contract/openapi.yaml`
- `docs/PR_9_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/013-offline-manifests.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Redeploy `api`.
- Env vars to add/update:
    - None.
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  **Audio Checking**: Try to publish a Tour with a text-only POI -> Expect 422 `audio_coverage`.
    2.  **Manifest Security**: Access manifest with random ID -> Expect 403.
    3.  **Download**: Access manifest with entitled ID -> Expect 200 + Assets JSON.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Remove Audio gate if blocking legacy content (unlikely for new app).

Validation step
- URLs:
  - <Preview URL> /v1/public/tours/{id}/manifest?city=...&device_anon_id=...
- Logs:
  - Vercel Logs: "Manifest Access" (if logged).

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: n/a
- DB / migrations: done
- Security: done (Entitlement Gate)
- Performance / caching: done (Private Cache)
- Observability / ops: done
- Testing: done (Flow validation)
- Mobile offline-first: done (Manifest)
- Publish gates: done (Audio Check)
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: n/a
- Privacy / Data safety / deletion: done
- Docs-as-code: done
- No-local: done
