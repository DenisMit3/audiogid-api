# api_client.api.AdminApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *https://audiogid-api.vercel.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**presignMedia**](AdminApi.md#presignmedia) | **POST** /admin/media/presign | Presign Media Upload


# **presignMedia**
> PresignResponse presignMedia(presignRequest)

Presign Media Upload

### Example
```dart
import 'package:api_client/api.dart';
// TODO Configure HTTP Bearer authorization: BearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final presignRequest = PresignRequest(); // PresignRequest | 

try {
    final result = api_instance.presignMedia(presignRequest);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->presignMedia: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **presignRequest** | [**PresignRequest**](PresignRequest.md)|  | 

### Return type

[**PresignResponse**](PresignResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

