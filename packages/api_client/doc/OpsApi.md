# api_client.api.OpsApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://82.202.159.64:8000/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getOpsCommit**](OpsApi.md#getopscommit) | **GET** /ops/commit | Get deployed commit info
[**getOpsHealth**](OpsApi.md#getopshealth) | **GET** /ops/health | Liveness and diagnostics probe
[**opsConfigCheckGet**](OpsApi.md#opsconfigcheckget) | **GET** /ops/config-check | Health and config check (Safe monitor)


# **getOpsCommit**
> GetOpsCommit200Response getOpsCommit()

Get deployed commit info

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = OpsApi();

try {
    final result = api_instance.getOpsCommit();
    print(result);
} catch (e) {
    print('Exception when calling OpsApi->getOpsCommit: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetOpsCommit200Response**](GetOpsCommit200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsHealth**
> OpsHealthResponse getOpsHealth()

Liveness and diagnostics probe

Returns 200 (OK) if healthy, 503 if partial failure (e.g. imports).

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = OpsApi();

try {
    final result = api_instance.getOpsHealth();
    print(result);
} catch (e) {
    print('Exception when calling OpsApi->getOpsHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**OpsHealthResponse**](OpsHealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

