# Runtime Smoke Report (auth/billing/offline)

Date: 2026-03-27

## Executed smoke checks

1. `POST /v1/auth/login/email` with invalid credentials -> expected `401`.
2. `POST /v1/billing/restore` with `platform=google` and missing purchase payload -> expected `400`.
3. `GET /v1/billing/entitlements` for unknown device -> expected `200` + empty list.
4. `POST /v1/offline/bundles:build` with missing `QSTASH_TOKEN` -> expected `503`.

All four checks are covered by `apps/api/tests/test_runtime_smoke.py`.

## Runtime issue fixed in this pass

- **Fixed:** `api/public.py` used `json.loads/json.dumps` in `/public/poi/{poi_id}` path but did not import `json`, which could raise `NameError` at runtime.

## Potential production-logic bug shortlist

1. **Unsafe migration endpoint semantics**
   - `/v1/force-migrate` is a `GET` route that performs DB schema mutation.
   - Recommendation: make it `POST` + admin auth (or internal-only).

2. **Dev-admin login endpoint in production binary**
   - `/auth/login/dev-admin` exists and mints admin tokens if secret matches.
   - Recommendation: disable endpoint outside non-prod envs, or require explicit feature flag.

3. **Billing restore idempotency scope is too broad**
   - `billing/restore` checks uniqueness only by `idempotency_key`.
   - Different devices/users/platforms can collide if they accidentally reuse key values.
   - Recommendation: namespace key using user/device/platform similarly to offline job key composition.

4. **QStash client initialized at import time**
   - `QStash(token=config.QSTASH_TOKEN)` is executed on module import.
   - Recommendation: lazy-init at request/runtime path or guard for empty/malformed token to avoid startup fragility.
