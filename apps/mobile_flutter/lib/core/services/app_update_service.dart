import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_service.g.dart';

class AppUpdateInfo {
  final bool updateRequired;
  final bool updateAvailable;
  final bool forceUpdate;
  final String minVersion;
  final String currentVersion;
  final String storeUrl;
  final String? messageRu;

  AppUpdateInfo({
    required this.updateRequired,
    required this.updateAvailable,
    required this.forceUpdate,
    required this.minVersion,
    required this.currentVersion,
    required this.storeUrl,
    this.messageRu,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateRequired: json['update_required'] ?? false,
      updateAvailable: json['update_available'] ?? false,
      forceUpdate: json['force_update'] ?? false,
      minVersion: json['min_version'] ?? '1.0.0',
      currentVersion: json['current_version'] ?? '1.0.0',
      storeUrl: json['store_url'] ?? '',
      messageRu: json['message_ru'],
    );
  }

  // Нет необходимости в обновлении
  factory AppUpdateInfo.upToDate() {
    return AppUpdateInfo(
      updateRequired: false,
      updateAvailable: false,
      forceUpdate: false,
      minVersion: '1.0.0',
      currentVersion: '1.0.0',
      storeUrl: '',
    );
  }
}

@riverpod
AppUpdateService appUpdateService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return AppUpdateService(config.apiBaseUrl);
}

class AppUpdateService {
  final String _baseUrl;
  final Dio _dio;

  AppUpdateService(this._baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final platform = Platform.isIOS ? 'ios' : 'android';

      final response = await _dio.get(
        '/ops/app-version',
        queryParameters: {
          'platform': platform,
          'version': version,
        },
      );

      if (response.statusCode == 200) {
        return AppUpdateInfo.fromJson(response.data);
      }

      return AppUpdateInfo.upToDate();
    } catch (e) {
      // При ошибке сети не блокируем приложение
      debugPrint('AppUpdateService error: $e');
      return AppUpdateInfo.upToDate();
    }
  }
}
