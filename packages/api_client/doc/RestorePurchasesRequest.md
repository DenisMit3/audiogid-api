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
**googlePurchaseToken** | **String** | A Google purchase token (optional if server has none) | [optional] 
**productId** | **String** | Product ID (Required for Google single-token verify) | [optional] 
**packageName** | **String** | Package Name (Optional, defaults to app) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


