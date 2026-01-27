# api_client.model.RestorePurchasesRequest

## Load the model package
```dart
import 'package:api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**platform** | **String** |  | [optional] [default to 'auto']
**idempotencyKey** | **String** |  | 
**deviceAnonId** | **String** |  | 
**appleReceipt** | **String** | Latest Apple App Store receipt (base64) | [optional] 
**googlePurchases** | [**List<GooglePurchaseItem>**](GooglePurchaseItem.md) | List of Google purchases to restore (Batch mode) | [optional] [default to const []]
**googlePurchaseToken** | **String** | DEPRECATED: Use google_purchases | [optional] 
**productId** | **String** | DEPRECATED: Use google_purchases | [optional] 
**packageName** | **String** | DEPRECATED: Use google_purchases | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


