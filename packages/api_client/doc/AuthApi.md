# api_client.api.AuthApi

## Load the API package
```dart
import 'package:api_client/api.dart';
```

All URIs are relative to *https://audiogid-api.vercel.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**loginSmsInit**](AuthApi.md#loginsmsinit) | **POST** /auth/login/sms/init | Init SMS Login
[**loginSmsVerify**](AuthApi.md#loginsmsverify) | **POST** /auth/login/sms/verify | Verify SMS Login
[**loginTelegram**](AuthApi.md#logintelegram) | **POST** /auth/login/telegram | Telegram Login
[**logout**](AuthApi.md#logout) | **POST** /auth/logout | Logout
[**me**](AuthApi.md#me) | **GET** /auth/me | Get Current User
[**refreshToken**](AuthApi.md#refreshtoken) | **POST** /auth/refresh | Refresh Access Token


# **loginSmsInit**
> LoginSmsInit200Response loginSmsInit(phoneInit)

Init SMS Login

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AuthApi();
final phoneInit = PhoneInit(); // PhoneInit | 

try {
    final result = api_instance.loginSmsInit(phoneInit);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->loginSmsInit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **phoneInit** | [**PhoneInit**](PhoneInit.md)|  | 

### Return type

[**LoginSmsInit200Response**](LoginSmsInit200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginSmsVerify**
> TokenResponse loginSmsVerify(phoneVerify)

Verify SMS Login

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AuthApi();
final phoneVerify = PhoneVerify(); // PhoneVerify | 

try {
    final result = api_instance.loginSmsVerify(phoneVerify);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->loginSmsVerify: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **phoneVerify** | [**PhoneVerify**](PhoneVerify.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginTelegram**
> TokenResponse loginTelegram(telegramLogin)

Telegram Login

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AuthApi();
final telegramLogin = TelegramLogin(); // TelegramLogin | 

try {
    final result = api_instance.loginTelegram(telegramLogin);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->loginTelegram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **telegramLogin** | [**TelegramLogin**](TelegramLogin.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> Logout200Response logout(refreshReq)

Logout

Revokes current access token and optional refresh token.

### Example
```dart
import 'package:api_client/api.dart';
// TODO Configure HTTP Bearer authorization: BearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();
final refreshReq = RefreshReq(); // RefreshReq | 

try {
    final result = api_instance.logout(refreshReq);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshReq** | [**RefreshReq**](RefreshReq.md)|  | [optional] 

### Return type

[**Logout200Response**](Logout200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **me**
> User me()

Get Current User

### Example
```dart
import 'package:api_client/api.dart';
// TODO Configure HTTP Bearer authorization: BearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('BearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();

try {
    final result = api_instance.me();
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->me: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshToken**
> TokenResponse refreshToken(refreshReq)

Refresh Access Token

### Example
```dart
import 'package:api_client/api.dart';

final api_instance = AuthApi();
final refreshReq = RefreshReq(); // RefreshReq | 

try {
    final result = api_instance.refreshToken(refreshReq);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->refreshToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshReq** | [**RefreshReq**](RefreshReq.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

