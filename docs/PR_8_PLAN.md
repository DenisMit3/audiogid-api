# IMPLEMENTATION PLAN — PR-8: Purchases (Server-Confirm)

## 1. Schema Updates
*   **PurchaseIntent**: Tracks the start of a transaction.
    *   `id`, `city_slug`, `tour_id`, `device_anon_id` (used for entitlement binding), `platform` (ios/android), `started_at`, `status` (PENDING, FAILED, COMPLETED).
    *   `idempotency_key` (Unique Constraint).
*   **Purchase**: Record of a successful transaction.
    *   `id`, `intent_id`, `store_proof` (encrypted/opaque), `store_transaction_id`, `purchased_at`.
*   **Entitlement**: The permission to access content.
    *   `id`, `city_slug`, `tour_id`, `device_anon_id`, `granted_at`, `revoked_at`.
    *   *Note*: Binding to `device_anon_id` means "restore purchases" logic relies on user restoring the same ID or we assume this is "device-bound" for MVP (offline-first onboarding).
*   **Indexes**: `device_anon_id` for fast entitlement lookup.

## 2. API Endpoints
*   `POST /v1/public/purchases/tours/intent`:
    *   Creates `PurchaseIntent`.
    *   Rate Limit: Basic check (e.g. max 5 pending intents per device).
*   `POST /v1/public/purchases/tours/confirm`:
    *   Validates `store_proof`.
    *   **Sandbox Mode**: If `STORE_SANDBOX=true`, accepts literal `"SANDBOX_SUCCESS"` as proof to simulate success.
    *   Updates Intent -> COMPLETED.
    *   Creates `Purchase` + `Entitlement`.
*   `GET /v1/public/entitlements`:
    *   Returns list of `tour_id`s for the given `city` and `device_anon_id`.

## 3. Security & Compliance
*   **No Wallet**: We do not store value.
*   **Logs**: `store_proof` is NEVER logged.
*   **Idempotency**: `confirm` endpoint requires key to prevent double-charging/double-granting.

## 4. Documentation
*   **ADR-012**: Server-Confirm Strategy.
*   **Runbook**: Steps to simulate purchase in Sandbox.

---

# Task Plan (PR-8)
1.  **Contract**: Update OpenAPI with Purchase endpoints.
2.  **Models**: Add Purchase/Entitlement models.
3.  **Migration**: `0007_pr8_purchases.py`.
4.  **Logic**: `apps/api/api/purchases.py`.
5.  **Router**: Mount in `index.py`.
6.  **Client**: Regenerate.
7.  **Docs**: ADR-012, `api.md`, `runbook.md`.

---

# ADR-012: Server-Confirm Purchases

## Context
We need to sell premium Tours. We must avoid "client-side trust" where the app simply says "I paid". We also want to avoid the complexity of a stored value wallet or account system for Day 1 (Offline-First).

## Decision
*   **Server-Side Confirmation**: The mobile app sends the receipt (Apple/Google) to the API. The API validates it (or mocks validation in Sandbox) and *then* grants an Entitlement.
*   **Device Binding**: Entitlements are bound to `device_anon_id`.
    *   *Tradeoff*: If user uninstalls/wipes info, they lose purchases unless they "Restore Purchases" via the Store (which allows us to re-validate the receipt and re-grant entitlement to the new `device_anon_id`).
    *   *Acceptance*: This matches the "Offline-First Onboarding" constraint.
*   **No Balances**: We settle strictly 1-to-1. Money in -> Content out.

## Consequences
*   Simplifies backend (no ledger needed).
*   High reliance on Store Receipt validation availability.
*   "Restore Purchases" feature on client becomes critical for retention.
