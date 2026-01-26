# Billing Service

High-level Flutter/Dart wrapper for Audiogid in-app purchases with server-side verification.

## Features

- ✅ Server-side receipt verification (Apple + Google)
- ✅ Local entitlement caching with TTL
- ✅ Automatic cache refresh after purchase
- ✅ Access check helpers
- ✅ Idempotent verification requests

## Usage

```dart
import 'package:billing_service/billing_service.dart';

// Initialize
final billing = BillingService(deviceAnonId: 'device-uuid');
await billing.initialize();

// Check access (uses cache)
if (billing.hasAccess('kaliningrad_city')) {
  // User has access to Kaliningrad city content
}

// After native purchase completes, verify with server:
final result = await billing.verifyApplePurchase(
  receipt: receiptData,
  productId: 'kaliningrad_city_access',
);

if (result.isSuccess) {
  print('Purchase verified! Grant ID: ${result.entitlementGrantId}');
  // Entitlements cache is automatically refreshed
}

// Fetch fresh entitlements from server
final entitlements = await billing.fetchEntitlements(forceRefresh: true);
```

## Integration with in_app_purchase

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

final iap = InAppPurchase.instance;

// Listen to purchases
iap.purchaseStream.listen((purchases) async {
  for (final purchase in purchases) {
    if (purchase.status == PurchaseStatus.purchased) {
      // Verify with our server
      PurchaseResult result;
      if (Platform.isIOS) {
        result = await billing.verifyApplePurchase(
          receipt: purchase.verificationData.localVerificationData,
          productId: purchase.productID,
        );
      } else {
        result = await billing.verifyGooglePurchase(
          purchaseToken: purchase.verificationData.serverVerificationData,
          productId: purchase.productID,
        );
      }
      
      if (result.isSuccess) {
        // Complete the purchase
        await iap.completePurchase(purchase);
      } else {
        // Handle verification failure
        print('Verification failed: ${result.error}');
      }
    }
  }
});
```

## Dependencies

- `api_client` - Generated API client from OpenAPI spec
- `shared_preferences` - Local caching
- `uuid` - Idempotency keys
