import 'dart:io';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var attempt = err.requestOptions.extra['retry_attempt'] ?? 0;

    if (_shouldRetry(err) && attempt < maxRetries) {
      attempt++;
      err.requestOptions.extra['retry_attempt'] = attempt;

      await Future.delayed(retryInterval * attempt);
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.unknown && err.error is SocketException ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
