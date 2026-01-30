import 'dart:io';
import 'package:dio/dio.dart';

class ErrorUtils {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Превышено время ожидания. Проверьте интернет.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
             return 'Ошибка авторизации. Попробуйте войти снова.';
          } else if (statusCode == 403) {
             return 'Доступ запрещен.';
          } else if (statusCode == 404) {
             return 'Ресурс не найден.';
          } else if (statusCode != null && statusCode >= 500) {
             return 'Ошибка сервера ($statusCode). Попробуйте позже.';
          }
          return 'Ошибка сервера: ${statusCode ?? 'Unknown'}';
        case DioExceptionType.cancel:
          return 'Запрос отменен.';
        case DioExceptionType.connectionError:
           if (error.error is SocketException) {
             return 'Нет подключения к интернету.';
           }
           return 'Ошибка подключения.';
        case DioExceptionType.unknown:
           if (error.error is SocketException) {
             return 'Нет подключения к интернету.';
           }
           return 'Произошла ошибка. Попробуйте снова.';
        default:
          return 'Ошибка сети.';
      }
    } else if (error is SocketException) {
      return 'Нет подключения к интернету.';
    } else if (error is FormatException) {
      return 'Ошибка обработки данных.';
    }
    
    return error.toString().replaceAll('Exception:', '').trim();
  }
  
  static String getFriendlyMessage(dynamic error) {
      // Alias for getErrorMessage
      return getErrorMessage(error);
  }
}
