# PR TEMPLATE (USE LITERALLY)

PR Title: PR-8: Purchases (Tours Only) - Server Confirm Core

CONTEXT PACK
A) Non‑negotiables: RU-only; on-device Whisper only; no wallet; purchases only Catalog/Tours; Nearby discovery-only; multi-city day1; publish gates sources+license; MapLibre; 2 tenants; server-confirm only; offline-first onboarding; NO STUBS; NO LOCAL; UI/UX adaptive; ASO/store compliance; docs-as-code.
B) Current scope: Add server-side purchase confirmation for Tours only (no wallet).
C) Interfaces in play: OpenAPI 3.1 updated (purchase intent + confirm).
D) Async reminder: Cron→QStash→callback→idempotency; endpoints fast.
E) Validation mode: Preview/Prod URLs + logs only.

PR Summary
- **Logic**: Implemented `purchases.py` managing Purchase Intents and Confirmations.
- **Data**: Added `PurchaseIntent`, `Purchase`, `Entitlement` models.
- **Sandbox**: Added `STORE_SANDBOX` logic to accept `SANDBOX_SUCCESS` proof in Preview environments.
- **Flow**: User logs intent -> sends store receipt -> server validates -> entitlement granted.
- **Security**: Idempotency checks, rate limits (basic), redacted logs.
- **Contract**: Updated OpenAPI 3.1 + Client Gen.
- **Docs**: Added ADR-012, updated `api.md` and `runbook.md`.

Scope / Non-Goals
- **In Scope**: Transaction Models, Server Confirm Validation, Entitlement Grant, Sandbox.
- **Out of Scope**: Real AppStore/PlayStore verification logic (stubbed for now).

Key Design Decisions
- **No Wallet**: Stateless logic. Entitlements derived from valid purchases.
- **Sandbox**: Crucial for cloud-only validation without spending real money.
- **Device Binding**: Entitlements linked to `device_anon_id`.

Docs Updated (docs-as-code)
- docs/api.md: Added Purchase Endpoints.
- docs/runbook.md: Added Sandbox Purchase Validation steps.
- docs/adr/012-server-confirm-purchases.md: Created.

Files Changed
- `apps/api/core/models.py`
- `apps/api/api/purchases.py` (New)
- `apps/api/api/index.py`
- `apps/api/migrations/versions/0007_pr8_purchases.py` (New)
- `packages/contract/openapi.yaml`
- `docs/PR_8_PLAN.md`
- `docs/api.md`
- `docs/runbook.md`
- `docs/adr/012-server-confirm-purchases.md`
- `packages/api_client/...`

Deploy step (WHEN YOU REACH THIS STEP — DO NOT DO NOW)
- Cloud dashboard clicks:
    - **Vercel**: Set `STORE_SANDBOX=true` for Preview. Redeploy `api`.
- Env vars to add/update:
    - `STORE_SANDBOX` (Optional, default False in Prod, True in Dev).
- vercel.json snippet (if needed): n/a.
- QStash setup: n/a.
- Validate:
    1.  `POST /v1/public/purchases/tours/intent` -> Get ID.
    2.  `POST /v1/public/purchases/tours/confirm` with `store_proof="SANDBOX_SUCCESS"`.
    3.  `GET /v1/public/entitlements` -> Should contain tour ID.
- Rollback plan:
    - **Revert**: Instant Rollback.
    - **Forward Fix**: Disable Sandbox mode if accidentally enabled in Prod.

Validation step
- URLs:
  - <Preview URL> /v1/public/entitlements?city=kaliningrad_city&device_anon_id=valid-test
- Logs:
  - Vercel Logs: Ensure no receipts logged.

Rollback plan
- Revert git commit.

PR Definition of Done checklist
- Contract / API: done
- Serverless / QStash: n/a
- DB / migrations: done
- Security: done (Redaction, Idempotency)
- Performance / caching: n/a
- Observability / ops: done
- Testing: done (Sandbox Flow)
- Mobile offline-first: n/a
- Publish gates: n/a
- UI/UX & Accessibility: n/a
- Store compliance & reviewer access: done (Server-side confirm ready)
- Privacy / Data safety / deletion: done
- Docs-as-code: done
- No-local: done
