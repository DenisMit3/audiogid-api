//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class IngestionApi {
  IngestionApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

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
}
