//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OfflineApi {
  OfflineApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Enqueue Offline Bundle Build
  ///
  /// Initiates async generation of an offline bundle manifest.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [BuildOfflineBundleRequest] buildOfflineBundleRequest (required):
  Future<Response> buildOfflineBundleWithHttpInfo(BuildOfflineBundleRequest buildOfflineBundleRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/offline/bundles:build';

    // ignore: prefer_final_locals
    Object? postBody = buildOfflineBundleRequest;

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

  /// Enqueue Offline Bundle Build
  ///
  /// Initiates async generation of an offline bundle manifest.
  ///
  /// Parameters:
  ///
  /// * [BuildOfflineBundleRequest] buildOfflineBundleRequest (required):
  Future<BuildOfflineBundle202Response?> buildOfflineBundle(BuildOfflineBundleRequest buildOfflineBundleRequest,) async {
    final response = await buildOfflineBundleWithHttpInfo(buildOfflineBundleRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BuildOfflineBundle202Response',) as BuildOfflineBundle202Response;
    
    }
    return null;
  }

  /// Get Bundle Job Status
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] jobId (required):
  Future<Response> getOfflineBundleStatusWithHttpInfo(String jobId,) async {
    // ignore: prefer_const_declarations
    final path = r'/offline/bundles/{job_id}'
      .replaceAll('{job_id}', jobId);

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

  /// Get Bundle Job Status
  ///
  /// Parameters:
  ///
  /// * [String] jobId (required):
  Future<OfflineJobRead?> getOfflineBundleStatus(String jobId,) async {
    final response = await getOfflineBundleStatusWithHttpInfo(jobId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OfflineJobRead',) as OfflineJobRead;
    
    }
    return null;
  }
}
