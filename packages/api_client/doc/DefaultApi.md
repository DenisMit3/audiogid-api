# api_client.api.DefaultApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *https://audiogid-api.vercel.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDeletionStatus**](DefaultApi.md#getdeletionstatus) | **GET** /public/account/delete/status | Check Deletion Status
[**getIngestionRuns**](DefaultApi.md#getingestionruns) | **GET** /admin/ingestion/runs | Get Ingestion Runs
[**opsConfigCheckGet**](DefaultApi.md#opsconfigcheckget) | **GET** /ops/config-check | Health and config check (Safe monitor)
[**publicCatalogGet**](DefaultApi.md#publiccatalogget) | **GET** /public/catalog | Get tours catalog for a city
[**publicCitiesGet**](DefaultApi.md#publiccitiesget) | **GET** /public/cities | Get active cities
[**publicPoiPoiIdGet**](DefaultApi.md#publicpoipoiidget) | **GET** /public/poi/{poi_id} | Get POI details with entitlement check
[**publicToursGet**](DefaultApi.md#publictoursget) | **GET** /public/tours | Get tours for a city
[**requestDeletion**](DefaultApi.md#requestdeletion) | **POST** /public/account/delete/request | Request Account Deletion


# **getDeletionStatus**
> GetDeletionStatus200Response getDeletionStatus(deletionRequestId)

Check Deletion Status

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final deletionRequestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getDeletionStatus(deletionRequestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getDeletionStatus: $e\n');
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

# **getIngestionRuns**
> List<IngestionRunRead> getIngestionRuns(city)

Get Ingestion Runs

Returns a list of recent ingestion runs with enrichment.

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final city = city_example; // String | 

try {
    final result = api_instance.getIngestionRuns(city);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getIngestionRuns: $e\n');
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

# **opsConfigCheckGet**
> OpsConfigCheckGet200Response opsConfigCheckGet()

Health and config check (Safe monitor)

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.opsConfigCheckGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->opsConfigCheckGet: $e\n');
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

# **publicCatalogGet**
> List<TourSnippet> publicCatalogGet(city, ifNoneMatch)

Get tours catalog for a city

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final city = city_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicCatalogGet(city, ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->publicCatalogGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **city** | **String**|  | 
 **ifNoneMatch** | **String**| ETag for conditional GET | [optional] 

### Return type

[**List<TourSnippet>**](TourSnippet.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicCitiesGet**
> List<City> publicCitiesGet(ifNoneMatch)

Get active cities

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicCitiesGet(ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->publicCitiesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ifNoneMatch** | **String**| ETag for conditional GET | [optional] 

### Return type

[**List<City>**](City.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicPoiPoiIdGet**
> PoiDetail publicPoiPoiIdGet(poiId, city, deviceAnonId, ifNoneMatch)

Get POI details with entitlement check

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final poiId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final city = city_example; // String | 
final deviceAnonId = deviceAnonId_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicPoiPoiIdGet(poiId, city, deviceAnonId, ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->publicPoiPoiIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poiId** | **String**|  | 
 **city** | **String**|  | 
 **deviceAnonId** | **String**|  | [optional] 
 **ifNoneMatch** | **String**| ETag for conditional GET | [optional] 

### Return type

[**PoiDetail**](PoiDetail.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicToursGet**
> publicToursGet(city, ifNoneMatch)

Get tours for a city

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final city = city_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    api_instance.publicToursGet(city, ifNoneMatch);
} catch (e) {
    print('Exception when calling DefaultApi->publicToursGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **city** | **String**|  | 
 **ifNoneMatch** | **String**| ETag for conditional GET | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestDeletion**
> RequestDeletion202Response requestDeletion(requestDeletionRequest)

Request Account Deletion

Initiates async deletion of user data.

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = DefaultApi();
final requestDeletionRequest = RequestDeletionRequest(); // RequestDeletionRequest | 

try {
    final result = api_instance.requestDeletion(requestDeletionRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->requestDeletion: $e\n');
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

