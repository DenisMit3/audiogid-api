import 'package:dio/dio.dart';

sealed class AppError implements Exception {
  final String message;
  AppError(this.message);
}

class NetworkError extends AppError {
  NetworkError() : super('Network connection issue');
}

class ServerError extends AppError {
  final int? statusCode;
  ServerError(this.statusCode) : super('Server returned error: $statusCode');
}

class AuthError extends AppError {
  AuthError() : super('Authentication failed');
}

class UnknownError extends AppError {
  UnknownError([String? msg]) : super(msg ?? 'An unknown error occurred');
}

class ApiErrorMapper {
  static AppError map(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return NetworkError();
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          if (status == 401 || status == 403) return AuthError();
          return ServerError(status);
        default:
          return UnknownError(error.message);
      }
    }
    return UnknownError(error.toString());
  }
}
