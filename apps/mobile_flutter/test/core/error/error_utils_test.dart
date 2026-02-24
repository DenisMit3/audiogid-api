import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/error/error_utils.dart';

void main() {
  group('ErrorUtils', () {
    test('should return friendly message for connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(ErrorUtils.getErrorMessage(error),
          'Превышено время ожидания. Проверьте интернет.');
    });

    test('should return friendly message for 401', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 401,
        ),
      );
      expect(ErrorUtils.getErrorMessage(error),
          'Ошибка авторизации. Попробуйте войти снова.');
    });

    test('should return friendly message for SocketException', () {
      final error = const SocketException('Failed');
      expect(ErrorUtils.getErrorMessage(error), 'Нет подключения к интернету.');
    });

    test('should return raw string if input is string', () {
      expect(ErrorUtils.getErrorMessage('Custom error'), 'Custom error');
    });
  });
}
