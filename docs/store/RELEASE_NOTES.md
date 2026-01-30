# Release Notes & Reviewer Guide

## Reviewer Access (Demo Account)
App is fully functional without login (Offline-first).
However, for testing paid features (if gated), use:

**Username:** demo@audiogid.app
**Password:** Demo1234
**(Note: Auth is currently disabled/optional in this build version)**

## Export Compliance
This app uses standard HTTPS encryption (TLS) for API calls. It does not use proprietary encryption.
**Export Compliance Code:** N/A (Self-exempt under ordinary mass market software)

## App Deletion
Account deletion is available in **Settings -> Delete Account**.
Since this version primarily uses local storage, this action clears local preferences and database.

## Testing Instructions
1.  **Launch:** App opens in "City Selection" mode (or defaults to defined city).
2.  **Permissions:** App will request Location permission for "Tour Mode" and "Nearby" features. Please grant "While Using App".
3.  **Tours:** Navigate to "Tours", select a tour, and verify the route map loads.
4.  **Offline:** Try downloading a tour (simulated).
