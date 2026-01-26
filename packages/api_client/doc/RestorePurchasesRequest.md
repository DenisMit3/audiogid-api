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
**googlePurchases** | [**List<RestorePurchasesRequestGooglePurchasesInner>**](RestorePurchasesRequestGooglePurchasesInner.md) | List of Google purchases to verify | [optional] [default to const []]
**googlePurchaseToken** | **String** | Legacy single token | [optional] 
**productId** | **String** | Legacy product ID for single token | [optional] 
**packageName** | **String** | Legacy package name for single token | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


