# ADR-012: Server-Confirm Purchases

## Context
We are introducing Premium Tours. We avoid a complex stored-value wallet in favor of a direct "Pay for Content" model. We must ensure purchases are validated on the server to prevent entitlement spoofing.

## Decision
*   **Server-Side Confirmation**: The mobile app initiates a purchase with the Store (Apple/Google), receives a receipt, and sends it to the API.
*   **Validation**: The API validates the receipt (or accepts a mock in Sandbox) before granting the Entitlement.
*   **Binding**: Entitlements are bound to `device_anon_id`. Note: Users must "Restore Purchases" if they change devices or wipe app data.
*   **No Balances**: The system is stateless regarding user funds. It only tracks "Access Granted".

## Consequences
*   **Security**: Minimal surface area. No money handling code on our backend (just verification).
*   **UX**: Users rely on offline on-device identifiers.
*   **Ops**: "Sandbox" mode required for Cloud Validation (Accepts `SANDBOX_SUCCESS`).
