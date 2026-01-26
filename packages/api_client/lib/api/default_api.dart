//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Check Deletion Status
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deletionRequestId (required):
  Future<Response> getDeletionStatusWithHttpInfo(String deletionRequestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/public/account/delete/status';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'deletion_request_id', deletionRequestId));

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

  /// Check Deletion Status
  ///
  /// Parameters:
  ///
  /// * [String] deletionRequestId (required):
  Future<GetDeletionStatus200Response?> getDeletionStatus(String deletionRequestId,) async {
    final response = await getDeletionStatusWithHttpInfo(deletionRequestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetDeletionStatus200Response',) as GetDeletionStatus200Response;
    
    }
    return null;
  }

  /// Get Ingestion Runs
  ///
  /// Returns a list of recent ingestion runs with enrichment.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] city:
  Future<Response> getIngestionRunsWithHttpInfo({ String? city, }) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/ingestion/runs';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (city != null) {
      queryParams.addAll(_queryParams('', 'city', city));
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

  /// Get Ingestion Runs
  ///
  /// Returns a list of recent ingestion runs with enrichment.
  ///
  /// Parameters:
  ///
  /// * [String] city:
  Future<List<IngestionRunRead>?> getIngestionRuns({ String? city, }) async {
    final response = await getIngestionRunsWithHttpInfo( city: city, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<IngestionRunRead>') as List)
        .cast<IngestionRunRead>()
        .toList(growable: false);

    }
    return null;
  }

  /// Health and config check (Safe monitor)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> opsConfigCheckGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/ops/config-check';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Health and config check (Safe monitor)
  Future<OpsConfigCheckGet200Response?> opsConfigCheckGet() async {
    final response = await opsConfigCheckGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OpsConfigCheckGet200Response',) as OpsConfigCheckGet200Response;
    
    }
    return null;
  }

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

  /// Request Account Deletion
  ///
  /// Initiates async deletion of user data.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RequestDeletionRequest] requestDeletionRequest (required):
  Future<Response> requestDeletionWithHttpInfo(RequestDeletionRequest requestDeletionRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/public/account/delete/request';

    // ignore: prefer_final_locals
    Object? postBody = requestDeletionRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Request Account Deletion
  ///
  /// Initiates async deletion of user data.
  ///
  /// Parameters:
  ///
  /// * [RequestDeletionRequest] requestDeletionRequest (required):
  Future<RequestDeletion202Response?> requestDeletion(RequestDeletionRequest requestDeletionRequest,) async {
    final response = await requestDeletionWithHttpInfo(requestDeletionRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RequestDeletion202Response',) as RequestDeletion202Response;
    
    }
    return null;
  }
}
