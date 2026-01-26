# api_client.api.BillingApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *https://audiogid-api.vercel.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getEntitlements**](BillingApi.md#getentitlements) | **GET** /billing/entitlements | Get current user entitlements
[**verifyAppleReceipt**](BillingApi.md#verifyapplereceipt) | **POST** /billing/apple/verify | Verify Apple App Store Receipt
[**verifyGooglePurchase**](BillingApi.md#verifygooglepurchase) | **POST** /billing/google/verify | Verify Google Play Purchase


# **getEntitlements**
> List<EntitlementGrantRead> getEntitlements(deviceAnonId)

Get current user entitlements

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = BillingApi();
final deviceAnonId = deviceAnonId_example; // String | 

try {
    final result = api_instance.getEntitlements(deviceAnonId);
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->getEntitlements: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceAnonId** | **String**|  | 

### Return type

[**List<EntitlementGrantRead>**](EntitlementGrantRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyAppleReceipt**
> PurchaseVerifyResponse verifyAppleReceipt(verifyAppleReceiptRequest)

Verify Apple App Store Receipt

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = BillingApi();
final verifyAppleReceiptRequest = VerifyAppleReceiptRequest(); // VerifyAppleReceiptRequest | 

try {
    final result = api_instance.verifyAppleReceipt(verifyAppleReceiptRequest);
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->verifyAppleReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyAppleReceiptRequest** | [**VerifyAppleReceiptRequest**](VerifyAppleReceiptRequest.md)|  | 

### Return type

[**PurchaseVerifyResponse**](PurchaseVerifyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyGooglePurchase**
> PurchaseVerifyResponse verifyGooglePurchase(verifyGooglePurchaseRequest)

Verify Google Play Purchase

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = BillingApi();
final verifyGooglePurchaseRequest = VerifyGooglePurchaseRequest(); // VerifyGooglePurchaseRequest | 

try {
    final result = api_instance.verifyGooglePurchase(verifyGooglePurchaseRequest);
    print(result);
} catch (e) {
    print('Exception when calling BillingApi->verifyGooglePurchase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyGooglePurchaseRequest** | [**VerifyGooglePurchaseRequest**](VerifyGooglePurchaseRequest.md)|  | 

### Return type

[**PurchaseVerifyResponse**](PurchaseVerifyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

