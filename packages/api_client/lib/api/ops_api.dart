//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OpsApi {
  OpsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get deployed commit info
  ///
  /// Note: This method returns the HTTP [Response].
  Future<http.Response> getOpsCommitWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/ops/commit';

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

  /// Get deployed commit info
  Future<GetOpsCommit200Response?> getOpsCommit() async {
    final response = await getOpsCommitWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetOpsCommit200Response',) as GetOpsCommit200Response;
    
    }
    return null;
  }

  /// Liveness and diagnostics probe
  ///
  /// Returns 200 (OK) if healthy, 503 if partial failure (e.g. imports).
  ///
  /// Note: This method returns the HTTP [Response].
  Future<http.Response> getOpsHealthWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/ops/health';

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

  /// Liveness and diagnostics probe
  ///
  /// Returns 200 (OK) if healthy, 503 if partial failure (e.g. imports).
  Future<OpsHealthResponse?> getOpsHealth() async {
    final response = await getOpsHealthWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OpsHealthResponse',) as OpsHealthResponse;
    
    }
    return null;
  }

  /// Health and config check (Safe monitor)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<http.Response> opsConfigCheckGetWithHttpInfo() async {
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
}
