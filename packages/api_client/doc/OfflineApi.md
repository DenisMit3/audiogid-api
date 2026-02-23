# api_client.api.OfflineApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://82.202.159.64:8000/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**buildOfflineBundle**](OfflineApi.md#buildofflinebundle) | **POST** /offline/bundles:build | Enqueue Offline Bundle Build
[**getOfflineBundleStatus**](OfflineApi.md#getofflinebundlestatus) | **GET** /offline/bundles/{job_id} | Get Bundle Job Status


# **buildOfflineBundle**
> BuildOfflineBundle202Response buildOfflineBundle(buildOfflineBundleRequest)

Enqueue Offline Bundle Build

Initiates async generation of an offline bundle manifest.

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = OfflineApi();
final buildOfflineBundleRequest = BuildOfflineBundleRequest(); // BuildOfflineBundleRequest | 

try {
    final result = api_instance.buildOfflineBundle(buildOfflineBundleRequest);
    print(result);
} catch (e) {
    print('Exception when calling OfflineApi->buildOfflineBundle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **buildOfflineBundleRequest** | [**BuildOfflineBundleRequest**](BuildOfflineBundleRequest.md)|  | 

### Return type

[**BuildOfflineBundle202Response**](BuildOfflineBundle202Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOfflineBundleStatus**
> OfflineJobRead getOfflineBundleStatus(jobId)

Get Bundle Job Status

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = OfflineApi();
final jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getOfflineBundleStatus(jobId);
    print(result);
} catch (e) {
    print('Exception when calling OfflineApi->getOfflineBundleStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  | 

### Return type

[**OfflineJobRead**](OfflineJobRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

