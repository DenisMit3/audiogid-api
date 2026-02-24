import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_health_service.g.dart';

@riverpod
ApiHealthService apiHealthService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ApiHealthService(config.apiBaseUrl);
}

class ApiHealthService {
  final String _baseUrl;
  final Dio _dio;

  ApiHealthService(this._baseUrl) : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<bool> checkHealth() async {
    try {
      final response =
          await _dio.get('/ops/health').timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
