import 'package:api_client/api.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:mobile_flutter/core/api/interceptors/auth_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/etag_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/logging_interceptor.dart';
import 'package:mobile_flutter/core/api/interceptors/retry_interceptor.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_provider.g.dart';
import 'package:dio_firebase_performance/dio_firebase_performance.dart';

@riverpod
Dio dio(DioRef ref) {
  final config = ref.watch(appConfigProvider);
  final db = ref.watch(appDatabaseProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Security: Certificate Pinning & Formatting
  // Note: For real pinning, we would load the certificate from assets here.
  // adapter.onHttpClientCreate = (client) {
  //   SecurityContext sc = SecurityContext();
  //   sc.setTrustedCertificatesBytes(loadedCertBytes);
  //   return HttpClient(context: sc);
  // };
  
  // For development with self-signed certs (if needed):
  // if (config.flavor == AppFlavor.dev) {
  //   (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
  //     client.badCertificateCallback = (cert, host, port) => true;
  //     return client;
  //   };
  // }

  dio.interceptors.addAll([
    AuthInterceptor(baseUrl: config.apiBaseUrl),
    EtagInterceptor(db.etagDao),
    LoggingInterceptor(),
    RetryInterceptor(dio: dio),
    DioFirebasePerformanceInterceptor(),
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

@riverpod
AuthApi authApi(AuthApiRef ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
}

@riverpod
OfflineApi offlineApi(OfflineApiRef ref) {
  final client = ref.watch(apiClientProvider);
  // OfflineApi might need explicit dio if not in the main client wrapper,
  // but ApiClient usually exposes getOfflineApi or similar, OR we use the default constructor wrapping dio.
  // Looking at Generated code pattern from other providers: `AuthApi(client)`.
  // If OfflineApi follows same pattern:
  return OfflineApi(client.dio, client.dio.options.baseUrl);
}
