# api_client.api.PublicApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *http://82.202.159.64:8000/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**publicCatalogGet**](PublicApi.md#publiccatalogget) | **GET** /public/catalog | Get tours catalog for a city
[**publicCitiesGet**](PublicApi.md#publiccitiesget) | **GET** /public/cities | Get active cities
[**publicPoiPoiIdGet**](PublicApi.md#publicpoipoiidget) | **GET** /public/poi/{poi_id} | Get POI details with entitlement check
[**publicToursGet**](PublicApi.md#publictoursget) | **GET** /public/tours | Get tours for a city


# **publicCatalogGet**
> List<TourSnippet> publicCatalogGet(city, ifNoneMatch)

Get tours catalog for a city

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = PublicApi();
final city = city_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicCatalogGet(city, ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling PublicApi->publicCatalogGet: $e\n');
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

final api_instance = PublicApi();
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicCitiesGet(ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling PublicApi->publicCitiesGet: $e\n');
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

final api_instance = PublicApi();
final poiId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final city = city_example; // String | 
final deviceAnonId = deviceAnonId_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    final result = api_instance.publicPoiPoiIdGet(poiId, city, deviceAnonId, ifNoneMatch);
    print(result);
} catch (e) {
    print('Exception when calling PublicApi->publicPoiPoiIdGet: $e\n');
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

final api_instance = PublicApi();
final city = city_example; // String | 
final ifNoneMatch = ifNoneMatch_example; // String | ETag for conditional GET

try {
    api_instance.publicToursGet(city, ifNoneMatch);
} catch (e) {
    print('Exception when calling PublicApi->publicToursGet: $e\n');
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

