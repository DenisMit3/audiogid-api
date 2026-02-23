# api_client.api.IngestionApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://82.202.159.64:8000/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getIngestionRuns**](IngestionApi.md#getingestionruns) | **GET** /admin/ingestion/runs | Get Ingestion Runs


# **getIngestionRuns**
> List<IngestionRunRead> getIngestionRuns(city)

Get Ingestion Runs

Returns a list of recent ingestion runs with enrichment.

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = IngestionApi();
final city = city_example; // String | 

try {
    final result = api_instance.getIngestionRuns(city);
    print(result);
} catch (e) {
    print('Exception when calling IngestionApi->getIngestionRuns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **city** | **String**|  | [optional] 

### Return type

[**List<IngestionRunRead>**](IngestionRunRead.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

