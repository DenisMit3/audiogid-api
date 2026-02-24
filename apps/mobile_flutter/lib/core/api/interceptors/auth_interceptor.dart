import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_client/api.dart';

class AuthInterceptor extends Interceptor {
  final String baseUrl;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  AuthInterceptor({required this.baseUrl});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_anon_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_anon_id', deviceId);
    }

    options.headers['X-Device-Anon-ID'] = deviceId;

    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final client = ApiClient(basePath: baseUrl);
          final authApi = AuthApi(client);

          final res = await authApi
              .refreshToken(RefreshReq(refreshToken: refreshToken));

          final newToken = res?.accessToken;
          final newRefresh = res?.refreshToken;

          if (newToken != null) {
            await _storage.write(key: 'jwt_token', value: newToken);
            if (newRefresh != null) {
              await _storage.write(key: 'refresh_token', value: newRefresh);
            }

            // Retry original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final dio = Dio(BaseOptions(baseUrl: baseUrl));
            final retryRes = await dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
                responseType: opts.responseType,
                contentType: opts.contentType,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            return handler.resolve(retryRes);
          }
        } catch (e) {
          // If refresh fails (blacklisted or expired), trigger full logout.
          await _storage.delete(key: 'jwt_token');
          await _storage.delete(key: 'refresh_token');
        }
      }
    }
    handler.next(err);
  }
}
