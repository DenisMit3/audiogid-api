# ADR-014: Deletion Strategy & Compliance

## Context
Apple and Google mandate user-initiated account/data deletion. Even with offline-first "Device ID" accounts, we must provide a mechanism to wipe server-side records.

## Decision
*   **Identification**: Deletion targets `device_anon_id`.
*   **Initiation**:
    *   **In-App**: Via API (Authenticated by possession of device).
    *   **Web**: Via HTML Form (User must manually provide ID from App Settings).
*   **Execution**: Async Background Job (QStash + Worker).
    *   *Why?* Deletion involves multiple table updates (Entitlements, Purchasing, Logs). Synchronous deletion risks timeout.
*   **Retention Rules**:
    *   **Entitlements**: Revoked (Soft Delete / Timestamped).
    *   **Intents**: Anonymized (Device ID hashed).
    *   **Purchases**: Transaction IDs retained for Tax/Legal compliance, but unlinked from user identity.
    *   **Requests**: Request log retained for 1 year as proof of compliance.

## Consequences
*   **Irreversible**: Once executed, entitlements are lost. "Restore Purchases" via Store is the only recovery path.
*   **Compliance**: Meets Apple Guideline 5.1.1(v) and Google Play Data Safety requirements.
