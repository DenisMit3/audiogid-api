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
Dio dio(DioRef ref) {
  final config = ref.watch(appConfigProvider);
  final db = ref.watch(appDatabaseProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.addAll([
    AuthInterceptor(),
    EtagInterceptor(db.etagDao),
    LoggingInterceptor(),
    RetryInterceptor(dio: dio),
  ]);

  return dio;
}

@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio: dio);
}

@riverpod
PublicApi publicApi(PublicApiRef ref) {
  final client = ref.watch(apiClientProvider);
  return PublicApi(client);
}

@riverpod
BillingApi billingApi(BillingApiRef ref) {
  final client = ref.watch(apiClientProvider);
  return BillingApi(client);
}

@riverpod
AccountApi accountApi(AccountApiRef ref) {
  final client = ref.watch(apiClientProvider);
  return AccountApi(client);
}
