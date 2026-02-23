import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/core/constants/offline_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'direct_download_service.g.dart';

enum DirectDownloadStage {
  idle,
  fetchingManifest,
  downloading,
  completed,
  failed,
}

class DirectDownloadStatus {
  final String citySlug;
  final double progress;
  final DirectDownloadStage stage;
  final String? error;
  final int totalAssets;
  final int downloadedAssets;

  DirectDownloadStatus({
    required this.citySlug,
    this.progress = 0.0,
    this.stage = DirectDownloadStage.idle,
    this.error,
    this.totalAssets = 0,
    this.downloadedAssets = 0,
  });

  DirectDownloadStatus copyWith({
    double? progress,
    DirectDownloadStage? stage,
    String? error,
    int? totalAssets,
    int? downloadedAssets,
  }) {
    return DirectDownloadStatus(
      citySlug: citySlug,
      progress: progress ?? this.progress,
      stage: stage ?? this.stage,
      error: error,
      totalAssets: totalAssets ?? this.totalAssets,
      downloadedAssets: downloadedAssets ?? this.downloadedAssets,
    );
  }
}

@Riverpod(keepAlive: true)
class DirectDownloadService extends _$DirectDownloadService {
  CancelToken? _cancelToken;

  @override
  Map<String, DirectDownloadStatus> build() {
    return {};
  }

  Future<void> startDownload(String citySlug) async {
    _cancelToken = CancelToken();
    
    state = {
      ...state,
      citySlug: DirectDownloadStatus(
        citySlug: citySlug,
        stage: DirectDownloadStage.fetchingManifest,
      )
    };

    try {
      final dio = ref.read(dioProvider);
      final config = ref.read(appConfigProvider);
      
      // 1. Получаем манифест города
      final manifestUrl = '${config.apiBaseUrl}/public/cities/$citySlug/offline-manifest';
      final manifestRes = await dio.get(manifestUrl, cancelToken: _cancelToken);
      final manifest = manifestRes.data as Map<String, dynamic>;
      
      final assets = (manifest['assets'] as List?) ?? [];
      final totalAssets = assets.length;
      
      if (totalAssets == 0) {
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.completed,
            progress: 1.0,
          )
        };
        return;
      }

      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(
          stage: DirectDownloadStage.downloading,
          totalAssets: totalAssets,
        )
      };

      // 2. Создаём директорию для загрузки
      final appDocDir = await getApplicationDocumentsDirectory();
      final cityDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, citySlug));
      if (!cityDir.existsSync()) {
        cityDir.createSync(recursive: true);
      }

      // 3. Загружаем каждый ресурс
      int downloaded = 0;
      final errors = <String>[];

      for (final asset in assets) {
        if (_cancelToken?.isCancelled ?? false) break;
        
        try {
          final url = asset['url'] as String?;
          final id = asset['id'] as String?;
          final type = asset['type'] as String? ?? 'file';
          
          if (url == null || id == null) continue;
          
          // Определяем расширение файла
          String ext = _getExtension(url, type);
          final filename = '$id$ext';
          final filePath = p.join(cityDir.path, filename);
          
          // Пропускаем если файл уже существует
          if (File(filePath).existsSync()) {
            downloaded++;
            _updateProgress(citySlug, downloaded, totalAssets);
            continue;
          }
          
          // Загружаем файл
          await dio.download(
            url,
            filePath,
            cancelToken: _cancelToken,
            options: Options(
              receiveTimeout: const Duration(seconds: 60),
            ),
          );
          
          downloaded++;
          _updateProgress(citySlug, downloaded, totalAssets);
          
        } catch (e) {
          errors.add(e.toString());
          // Продолжаем загрузку остальных файлов
        }
      }

      // 4. Сохраняем манифест локально
      final manifestFile = File(p.join(cityDir.path, 'manifest.json'));
      await manifestFile.writeAsString(manifestRes.data.toString());

      // 5. Завершаем
      if (_cancelToken?.isCancelled ?? false) {
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.failed,
            error: 'Загрузка отменена',
          )
        };
      } else if (errors.length > totalAssets / 2) {
        // Если больше половины файлов не загрузились - ошибка
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.failed,
            error: 'Не удалось загрузить ${errors.length} из $totalAssets файлов',
          )
        };
      } else {
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.completed,
            progress: 1.0,
            downloadedAssets: downloaded,
          )
        };
        
        // Обновляем список загруженных городов
        ref.invalidate(directDownloadedCitiesProvider);
      }

    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.failed,
            error: 'Загрузка отменена',
          )
        };
      } else {
        state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(
            stage: DirectDownloadStage.failed,
            error: e.toString(),
          )
        };
      }
    }
  }

  void _updateProgress(String citySlug, int downloaded, int total) {
    final progress = total > 0 ? downloaded / total : 0.0;
    state = {
      ...state,
      citySlug: state[citySlug]!.copyWith(
        progress: progress,
        downloadedAssets: downloaded,
      )
    };
  }

  String _getExtension(String url, String type) {
    // Пробуем получить расширение из URL
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final pathExt = p.extension(uri.path);
      if (pathExt.isNotEmpty) return pathExt;
    }
    
    // Fallback по типу
    switch (type) {
      case 'audio':
        return '.mp3';
      case 'image':
        return '.jpg';
      case 'video':
        return '.mp4';
      default:
        return '';
    }
  }

  void cancelDownload(String citySlug) {
    _cancelToken?.cancel();
    state = {
      ...state,
      citySlug: state[citySlug]!.copyWith(
        stage: DirectDownloadStage.failed,
        error: 'Загрузка отменена',
      )
    };
  }

  Future<void> deleteBundle(String citySlug) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final cityDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, citySlug));
      
      if (await cityDir.exists()) {
        await cityDir.delete(recursive: true);
      }
      
      // Убираем из состояния
      final newState = Map<String, DirectDownloadStatus>.from(state);
      newState.remove(citySlug);
      state = newState;
      
      ref.invalidate(directDownloadedCitiesProvider);
    } catch (e) {
      // Игнорируем ошибки удаления
    }
  }
}

@riverpod
Future<List<String>> directDownloadedCities(Ref ref) async {
  // Следим за изменениями в сервисе загрузки
  ref.watch(directDownloadServiceProvider);
  
  final appDocDir = await getApplicationDocumentsDirectory();
  final offlineDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir));
  
  if (!await offlineDir.exists()) return [];
  
  final list = <String>[];
  await for (final entity in offlineDir.list()) {
    if (entity is Directory) {
      final name = p.basename(entity.path);
      // Проверяем что есть manifest.json
      final manifestFile = File(p.join(entity.path, 'manifest.json'));
      if (await manifestFile.exists()) {
        list.add(name);
      }
    }
  }
  return list;
}
