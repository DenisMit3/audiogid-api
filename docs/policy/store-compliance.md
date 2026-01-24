# Store Compliance Policy

## Data Deletion (App Store 5.1.1v / Google Play Data Safety)

### 1. In-App Deletion
*   **Location**: Settings -> About -> **Delete My Data**.
*   **Flow**:
    1.  User clicks "Delete".
    2.  App calls `POST /account/delete/token` to get a proof signature.
    3.  App calls `POST /account/delete/request` with the ID and Token.
    4.  App confirms "Request Pending" and locally clears data/entitlements.

### 2. Web Deletion (External)
*   **URL**: `https://api.mambax.app/v1/delete`
*   **Requirement**: User must provide their `Device ID` and `Deletion Token` (displayed in App Settings).
*   **Rationale**: Ensures Proof-of-Possession. If user cannot provide these (e.g. uninstalled app), anonymous records are already orphaned/inaccessible and pose no privacy risk.

### 3. Retention
*   **Identity**: Hashed/Anonymized immediately.
*   **Purchases**: Transaction IDs retained for Tax/Legal compliance (unlinked).
*   **Entitlements**: Immediate Revocation.
