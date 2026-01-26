//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PublicApi {
  PublicApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get tours catalog for a city
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] city (required):
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<Response> publicCatalogGetWithHttpInfo(String city, { String? ifNoneMatch, }) async {
    // ignore: prefer_const_declarations
    final path = r'/public/catalog';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'city', city));

    if (ifNoneMatch != null) {
      headerParams[r'If-None-Match'] = parameterToString(ifNoneMatch);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get tours catalog for a city
  ///
  /// Parameters:
  ///
  /// * [String] city (required):
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<List<TourSnippet>?> publicCatalogGet(String city, { String? ifNoneMatch, }) async {
    final response = await publicCatalogGetWithHttpInfo(city,  ifNoneMatch: ifNoneMatch, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TourSnippet>') as List)
        .cast<TourSnippet>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get active cities
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<Response> publicCitiesGetWithHttpInfo({ String? ifNoneMatch, }) async {
    // ignore: prefer_const_declarations
    final path = r'/public/cities';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (ifNoneMatch != null) {
      headerParams[r'If-None-Match'] = parameterToString(ifNoneMatch);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get active cities
  ///
  /// Parameters:
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<List<City>?> publicCitiesGet({ String? ifNoneMatch, }) async {
    final response = await publicCitiesGetWithHttpInfo( ifNoneMatch: ifNoneMatch, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<City>') as List)
        .cast<City>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get POI details with entitlement check
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] poiId (required):
  ///
  /// * [String] city (required):
  ///
  /// * [String] deviceAnonId:
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<Response> publicPoiPoiIdGetWithHttpInfo(String poiId, String city, { String? deviceAnonId, String? ifNoneMatch, }) async {
    // ignore: prefer_const_declarations
    final path = r'/public/poi/{poi_id}'
      .replaceAll('{poi_id}', poiId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'city', city));
    if (deviceAnonId != null) {
      queryParams.addAll(_queryParams('', 'device_anon_id', deviceAnonId));
    }

    if (ifNoneMatch != null) {
      headerParams[r'If-None-Match'] = parameterToString(ifNoneMatch);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get POI details with entitlement check
  ///
  /// Parameters:
  ///
  /// * [String] poiId (required):
  ///
  /// * [String] city (required):
  ///
  /// * [String] deviceAnonId:
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<PoiDetail?> publicPoiPoiIdGet(String poiId, String city, { String? deviceAnonId, String? ifNoneMatch, }) async {
    final response = await publicPoiPoiIdGetWithHttpInfo(poiId, city,  deviceAnonId: deviceAnonId, ifNoneMatch: ifNoneMatch, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PoiDetail',) as PoiDetail;
    
    }
    return null;
  }

  /// Get tours for a city
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] city (required):
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<Response> publicToursGetWithHttpInfo(String city, { String? ifNoneMatch, }) async {
    // ignore: prefer_const_declarations
    final path = r'/public/tours';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'city', city));

    if (ifNoneMatch != null) {
      headerParams[r'If-None-Match'] = parameterToString(ifNoneMatch);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get tours for a city
  ///
  /// Parameters:
  ///
  /// * [String] city (required):
  ///
  /// * [String] ifNoneMatch:
  ///   ETag for conditional GET
  Future<void> publicToursGet(String city, { String? ifNoneMatch, }) async {
    final response = await publicToursGetWithHttpInfo(city,  ifNoneMatch: ifNoneMatch, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
