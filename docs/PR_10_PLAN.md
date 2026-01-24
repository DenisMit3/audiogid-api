# IMPLEMENTATION PLAN — PR-10: Store Compliance (Deletion & Retention)

## 1. Goal
Satisfy Apple App Store (Guideline 5.1.1(v) - In-App Deletion) and Google Play (Data Safety - Web Deletion) requirements. Enable user-initiated deletion of account/device data securely.

## 2. API Schema
*   `POST /v1/public/account/delete/request`: Initiates request.
    *   **Body**: `subject_id`, `idempotency_key`.
    *   **Logic**: Creates `DeletionRequest` (PENDING).
    *   **Auth**: Currently `device_anon_id` is passed as proof of possession.
*   `POST /v1/public/account/delete/confirm`: (Optional/Immediate)
    *   For MVP device-based auth, assuming `request` acts as confirmation if no email loop is possible.
    *   *Decision*: Immediate trigger for device-based flow to simplify offline-first UX.
    *   **Async Job**: Enqueues `delete_data` job.
*   `GET /v1/public/account/delete/status`: Poll status.
*   **Web Form**: Basic HTML endpoint `GET /delete` that calls `/v1/public/account/delete/request` (Requires user to manually input `device_anon_id` found in app settings, or we link via deeplink/token pattern if complex login exists. For offline-first, manual ID input is safest MVP for web).

## 3. Data Model
*   `DeletionRequest`: `id`, `subject_id`, `status` (PENDING, PROCESSING, COMPLETED, FAILED), `created_at`, `completed_at`, `log_json` (audit summary).
*   **Retention Policy**:
    *   `Entitlement`: **Revoked** (soft delete `revoked_at` set).
    *   `PurchaseIntent`: **Anonymize** (hash subject_id).
    *   `Purchase`: **Retain** transaction artifacts (Store ID) for compliance/tax, **Anonymize** link to user.
    *   `DeletionRequest`: **Retain** for 1 year (Proof of Deletion).

## 4. Documentation
*   **ADR-014**: Deletion Strategy & Compliance.
*   **Policy Doc**: `docs/policy/store-compliance.md`.
*   **Runbook**: End-to-end deletion test.

---

# Task Plan (PR-10)
1.  **Models**: `DeletionRequest` model in `models.py`.
2.  **Migration**: `0009_pr10_deletion.py`.
3.  **Public/Web Logic**: `apps/api/api/deletion.py`.
    *   Includes HTML form helper.
    *   Async Job enqueuer.
4.  **Worker**: Update `process_job` to handle `delete_user_data` task.
5.  **Contract**: Update OpenAPI (`/account/delete/*`).
6.  **Docs**: ADR-014, `policy/store-compliance.md`, `runbook.md`.

---

# ADR-014: Deletion Strategy & Compliance

## Context
Apple and Google mandate user-initiated account deletion. We operate on `device_anon_id` without email/phone.

## Decision
*   **Identifier**: Deletion targets `device_anon_id`.
*   **Verification**: 
    *   *In-App*: Sending the `device_anon_id` in header/body from that device is Proof of Possession.
    *   *Web*: User MUST manually find their ID in App Settings -> "About" to create a web request. This satisfies Google Play's "Web Deletion" requirement for uninstalled apps (user must have recorded their ID or lost data anyway).
*   **Async Execution**: Deletion is heavy (multiple tables). It runs via QStash job.
*   **Retention**:
    *   **Purchases**: Anonymized but retained (Legal/Tax/Accounting).
    *   **Entitlements**: Revoked immediately.
    *   **Intents**: Anonymized.

## Consequences
*   If a user wipes their device BEFORE checking their ID, they cannot use Web Deletion (acceptable as data is effectively orphaned/lost).
*   Future Account system must integrate here (ID -> AccountID).
