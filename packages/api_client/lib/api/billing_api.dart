//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BillingApi {
  BillingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get current user entitlements
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deviceAnonId (required):
  Future<Response> getEntitlementsWithHttpInfo(String deviceAnonId,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/entitlements';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'device_anon_id', deviceAnonId));

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

  /// Get current user entitlements
  ///
  /// Parameters:
  ///
  /// * [String] deviceAnonId (required):
  Future<List<EntitlementGrantRead>?> getEntitlements(String deviceAnonId,) async {
    final response = await getEntitlementsWithHttpInfo(deviceAnonId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<EntitlementGrantRead>') as List)
        .cast<EntitlementGrantRead>()
        .toList(growable: false);

    }
    return null;
  }

  /// Verify Apple App Store Receipt
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [VerifyAppleReceiptRequest] verifyAppleReceiptRequest (required):
  Future<Response> verifyAppleReceiptWithHttpInfo(VerifyAppleReceiptRequest verifyAppleReceiptRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/apple/verify';

    // ignore: prefer_final_locals
    Object? postBody = verifyAppleReceiptRequest;

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

  /// Verify Apple App Store Receipt
  ///
  /// Parameters:
  ///
  /// * [VerifyAppleReceiptRequest] verifyAppleReceiptRequest (required):
  Future<PurchaseVerifyResponse?> verifyAppleReceipt(VerifyAppleReceiptRequest verifyAppleReceiptRequest,) async {
    final response = await verifyAppleReceiptWithHttpInfo(verifyAppleReceiptRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseVerifyResponse',) as PurchaseVerifyResponse;
    
    }
    return null;
  }

  /// Verify Google Play Purchase
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [VerifyGooglePurchaseRequest] verifyGooglePurchaseRequest (required):
  Future<Response> verifyGooglePurchaseWithHttpInfo(VerifyGooglePurchaseRequest verifyGooglePurchaseRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/google/verify';

    // ignore: prefer_final_locals
    Object? postBody = verifyGooglePurchaseRequest;

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

  /// Verify Google Play Purchase
  ///
  /// Parameters:
  ///
  /// * [VerifyGooglePurchaseRequest] verifyGooglePurchaseRequest (required):
  Future<PurchaseVerifyResponse?> verifyGooglePurchase(VerifyGooglePurchaseRequest verifyGooglePurchaseRequest,) async {
    final response = await verifyGooglePurchaseWithHttpInfo(verifyGooglePurchaseRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseVerifyResponse',) as PurchaseVerifyResponse;
    
    }
    return null;
  }
}
