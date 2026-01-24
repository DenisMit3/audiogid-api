# Store Compliance Policy

## Status: READY

### Data Deletion (App Store 5.1.1v / Google Play Data Safety)
*   [x] **In-App Deletion**: Exists in Settings. API: `POST /account/delete/request`.
*   [x] **Web Deletion**: URL: `https://api.mambax.app/v1/delete`.
*   [x] **Security**: Proof-of-Possession Token (HMAC signed by server, 1h TTL).
*   [x] **Retention**: Identity hashed immediately. Financial records retained (unlinked).

### Launch Prep Checklist
*   [x] **Content Rights**: Published Tours gated by Source/License check.
*   [x] **Audio Quality**: Published Tours gated by Audio coverage check.
*   [x] **Privacy**:
    *   No logs with raw PII.
    *   Manifest endpoint secured (Payment Required).
    *   Cache-Control: `no-store` on sensitive user data.
*   [x] **Performance**:
    *   Rate Limits (Soft caps via payload).
    *   Security Headers (HSTS, etc).
