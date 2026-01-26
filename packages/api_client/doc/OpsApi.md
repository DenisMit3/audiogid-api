# api_client.api.OpsApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *https://audiogid-api.vercel.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**opsConfigCheckGet**](OpsApi.md#opsconfigcheckget) | **GET** /ops/config-check | Health and config check (Safe monitor)


# **opsConfigCheckGet**
> OpsConfigCheckGet200Response opsConfigCheckGet()

Health and config check (Safe monitor)

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = OpsApi();

try {
    final result = api_instance.opsConfigCheckGet();
    print(result);
} catch (e) {
    print('Exception when calling OpsApi->opsConfigCheckGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OpsConfigCheckGet200Response**](OpsConfigCheckGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

