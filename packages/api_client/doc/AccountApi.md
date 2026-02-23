# api_client.api.AccountApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://82.202.159.64:8000/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDeletionStatus**](AccountApi.md#getdeletionstatus) | **GET** /public/account/delete/status | Check Deletion Status
[**requestDeletion**](AccountApi.md#requestdeletion) | **POST** /public/account/delete/request | Request Account Deletion


# **getDeletionStatus**
> GetDeletionStatus200Response getDeletionStatus(deletionRequestId)

Check Deletion Status

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AccountApi();
final deletionRequestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getDeletionStatus(deletionRequestId);
    print(result);
} catch (e) {
    print('Exception when calling AccountApi->getDeletionStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deletionRequestId** | **String**|  | 

### Return type

[**GetDeletionStatus200Response**](GetDeletionStatus200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestDeletion**
> RequestDeletion202Response requestDeletion(requestDeletionRequest)

Request Account Deletion

Initiates async deletion of user data.

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AccountApi();
final requestDeletionRequest = RequestDeletionRequest(); // RequestDeletionRequest | 

try {
    final result = api_instance.requestDeletion(requestDeletionRequest);
    print(result);
} catch (e) {
    print('Exception when calling AccountApi->requestDeletion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestDeletionRequest** | [**RequestDeletionRequest**](RequestDeletionRequest.md)|  | 

### Return type

[**RequestDeletion202Response**](RequestDeletion202Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

