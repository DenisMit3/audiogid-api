//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Init SMS Login
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PhoneInit] phoneInit (required):
  Future<Response> loginSmsInitWithHttpInfo(PhoneInit phoneInit,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login/sms/init';

    // ignore: prefer_final_locals
    Object? postBody = phoneInit;

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

  /// Init SMS Login
  ///
  /// Parameters:
  ///
  /// * [PhoneInit] phoneInit (required):
  Future<LoginSmsInit200Response?> loginSmsInit(PhoneInit phoneInit,) async {
    final response = await loginSmsInitWithHttpInfo(phoneInit,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LoginSmsInit200Response',) as LoginSmsInit200Response;
    
    }
    return null;
  }

  /// Verify SMS Login
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PhoneVerify] phoneVerify (required):
  Future<Response> loginSmsVerifyWithHttpInfo(PhoneVerify phoneVerify,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login/sms/verify';

    // ignore: prefer_final_locals
    Object? postBody = phoneVerify;

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

  /// Verify SMS Login
  ///
  /// Parameters:
  ///
  /// * [PhoneVerify] phoneVerify (required):
  Future<TokenResponse?> loginSmsVerify(PhoneVerify phoneVerify,) async {
    final response = await loginSmsVerifyWithHttpInfo(phoneVerify,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Telegram Login
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [TelegramLogin] telegramLogin (required):
  Future<Response> loginTelegramWithHttpInfo(TelegramLogin telegramLogin,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login/telegram';

    // ignore: prefer_final_locals
    Object? postBody = telegramLogin;

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

  /// Telegram Login
  ///
  /// Parameters:
  ///
  /// * [TelegramLogin] telegramLogin (required):
  Future<TokenResponse?> loginTelegram(TelegramLogin telegramLogin,) async {
    final response = await loginTelegramWithHttpInfo(telegramLogin,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Logout
  ///
  /// Revokes current access token and optional refresh token.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshReq] refreshReq:
  Future<Response> logoutWithHttpInfo({ RefreshReq? refreshReq, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody = refreshReq;

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

  /// Logout
  ///
  /// Revokes current access token and optional refresh token.
  ///
  /// Parameters:
  ///
  /// * [RefreshReq] refreshReq:
  Future<Logout200Response?> logout({ RefreshReq? refreshReq, }) async {
    final response = await logoutWithHttpInfo( refreshReq: refreshReq, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Logout200Response',) as Logout200Response;
    
    }
    return null;
  }

  /// Get Current User
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> meWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/auth/me';

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

  /// Get Current User
  Future<User?> me() async {
    final response = await meWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
  }

  /// Refresh Access Token
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshReq] refreshReq (required):
  Future<Response> refreshTokenWithHttpInfo(RefreshReq refreshReq,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshReq;

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

  /// Refresh Access Token
  ///
  /// Parameters:
  ///
  /// * [RefreshReq] refreshReq (required):
  Future<TokenResponse?> refreshToken(RefreshReq refreshReq,) async {
    final response = await refreshTokenWithHttpInfo(refreshReq,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }
}
