//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AccountApi {
  AccountApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

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
