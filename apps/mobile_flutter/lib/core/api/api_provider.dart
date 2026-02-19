import 'package:api_client/api.dart';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/api/interceptors/auth_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/etag_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/logging_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/retry_interceptor.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final db = ref.watch(appDatabaseProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.addAll([
    AuthInterceptor(baseUrl: config.apiBaseUrl),
    EtagInterceptor(db.etagDao),
    LoggingInterceptor(),
    RetryInterceptor(dio: dio),
  ]);

  return dio;
}

@riverpod
ApiClient apiClient(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(basePath: config.apiBaseUrl);
}

@riverpod
PublicApi publicApi(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return PublicApi(client);
}

@riverpod
BillingApi billingApi(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return BillingApi(client);
}

@riverpod
AccountApi accountApi(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AccountApi(client);
}

@riverpod
AuthApi authApi(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
}

@riverpod
OfflineApi offlineApi(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return OfflineApi(client);
}
