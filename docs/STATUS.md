# Project Status Tracker

Living document tracking the implementation status of features defined in `PRODUCT.md`.

## Legend
- ✅ **Done**: Implemented, tested, and merged.
- 🚧 **In Progress**: Currently being developed.
- ⚠️ **Partial**: API exists, but Client/UI is missing.
- ❌ **Not Started**: Planned but not yet touched.

---

## 0) Tenants
- ✅ **kaliningrad_city**: Supported in DB & API.
- ✅ **kaliningrad_oblast**: Supported in DB & API.

## 1) Core
- ✅ **Offline-first API**: Public endpoints support ETag/Caching.
- ❌ **Offline-first Client**: Flutter app not started.
- ✅ **Entitlements**: Server-side logic implemented.

## 2) Onboarding
- ⚠️ **Offline-first onboarding**: API ready (no auth required), Client UI missing.
- ❌ **Login Flow**: SMS/Telegram auth not implemented.

## 3) Monetization & Payments
- ✅ **YooKassa Webhook**: Implemented & verified.
- ✅ **Apple Receipt Verify**: Implemented.
- ✅ **Google Play Verify**: Implemented (including Batch Restore).
- ✅ **Billing Restore**: Server-side reconcile implemented (Background Worker).
- ✅ **Idempotency**: Strict checks in place.
- ❌ **Client Purchase Flow**: StoreKit/BillingClient integration missing.

## 4) Feature Set (API Status / Client Status)
| Feature | API | Client (Mobile) | Admin (Edit) |
| :--- | :---: | :---: | :---: |
| **City Select** | ✅ | ❌ | ❌ |
| **Tours List/Detail** | ✅ | ❌ | ⚠️ (Read-only) |
| **Catalog** | ✅ | ❌ | ❌ |
| **Nearby** | ✅ | ❌ | N/A |
| **POI Detail** | ✅ | ❌ | ❌ |
| **Tour Mode (Nav)** | N/A | ❌ | N/A |
| **Free Walking Mode** | N/A | ❌ | N/A |
| **Museum Mode (QR)** | ❌ | ❌ | ❌ |
| **Itineraries** | ❌ | ❌ | N/A |
| **Helpers Nearby** | ✅ | ❌ | ❌ |
| **Kids Mode** | ❌ | ❌ | ❌ |
| **SOS / Share** | ❌ | ❌ | N/A |

## 5) Ingestion & Content
- ✅ **OSM Import**: Implemented (City + Helpers).
- ✅ **Async Jobs**: QStash worker pipeline operational.
- ✅ **Offline Bundles**: Generator implemented (ZIP + Manifest).
- ❌ **Manual Editing**: Admin endpoints for CRUD POI/Tours missing.
- ❌ **Audio Upload**: Not implemented in Admin.

## 6) Growth & Attribution
- ❌ **Deep Links**: No routing logic yet.
- ❌ **Partners**: Schema not designed.
- ❌ **Campaigns**: Schema not designed.

## 7) Compliance & Ops
- ✅ **Fail-fast Config**: Implemented.
- ✅ **Observability**: Structured JSON logs.
- ✅ **OpenAPI Sync**: CI check failing-on-diff.
- ❌ **Privacy Policy**: URL not served.
- ❌ **Delete Account**: API exists (`/deletion`), Client UI missing.

## Next High Priority Targets
1. **Auth (SMS/Telegram)**: Foundation for Admin & User profiles.
2. **Admin Content Management**: CRUD for POIs/Tours to enable content team.
3. **Flutter App Bootstrap**: basic shell + offline logic.
