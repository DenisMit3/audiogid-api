import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/services/direct_download_service.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/data/services/storage_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mobile_flutter/core/constants/offline_constants.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/spacing.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';
import 'package:mobile_flutter/presentation/widgets/common/glass_widgets.dart';
import 'package:mobile_flutter/presentation/widgets/common/skeleton_loader.dart';
import 'dart:io';

class OfflineManagerScreen extends ConsumerWidget {
  const OfflineManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityDao = ref.watch(appDatabaseProvider).cityDao;

    return Scaffold(
      appBar: AppBar(title: const Text('Оффлайн режим')),
      body: StreamBuilder<List<City>>(
        stream: cityDao.watchAllCities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cities = snapshot.data!;

          if (cities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Нет доступных городов для загрузки',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _StorageHeader()),
              const SliverToBoxAdapter(child: _InfoCard()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final city = cities[index];
                    return _CityDownloadTile(city: city);
                  },
                  childCount: cities.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.accentPrimary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Загрузите город для прослушивания экскурсий без интернета',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageHeader extends ConsumerWidget {
  const _StorageHeader();

  Future<Map<String, int>> _getStorageInfo(WidgetRef ref) async {
    final manager = ref.read(storageManagerProvider.notifier);
    final free = await manager.getFreeDiskSpace();

    final appDocDir = await getApplicationDocumentsDirectory();
    final offlineDir =
        Directory(p.join(appDocDir.path, OfflineConstants.offlineDir));
    final used = await manager.getDirectorySize(offlineDir);

    return {'free': free, 'used': used};
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, int>>(
      future: _getStorageInfo(ref),
      builder: (context, snapshot) {
        final free = snapshot.data?['free'] ?? 0;
        final used = snapshot.data?['used'] ?? 0;
        final hasData = snapshot.hasData;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Хранилище',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Использовано: ${hasData ? _formatBytes(used) : '...'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Свободно: ${hasData ? _formatBytes(free) : '...'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (hasData && (free + used) > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: LinearProgressIndicator(
                      value: used / (free + used + 1),
                      backgroundColor: AppColors.bgPrimary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accentPrimary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CityDownloadTile extends ConsumerWidget {
  final City city;
  const _CityDownloadTile({required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedListAsync = ref.watch(directDownloadedCitiesProvider);
    final downloadState = ref.watch(directDownloadServiceProvider);

    final status = downloadState[city.slug];
    final isActive = status != null &&
        status.stage != DirectDownloadStage.idle &&
        status.stage != DirectDownloadStage.completed &&
        status.stage != DirectDownloadStage.failed;

    final isDownloaded =
        downloadedListAsync.value?.contains(city.slug) ?? false;
    final hasFailed = status?.stage == DirectDownloadStage.failed;

    Widget trailing;

    if (isActive) {
      // Загрузка в процессе
      trailing = SizedBox(
        width: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            LinearProgressIndicator(value: status!.progress),
            const SizedBox(height: 4),
            Text(
              _getStageText(
                  status.stage, status.downloadedAssets, status.totalAssets),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    } else if (hasFailed) {
      // Ошибка загрузки
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Повторить',
            onPressed: () {
              ref
                  .read(directDownloadServiceProvider.notifier)
                  .startDownload(city.slug);
            },
          ),
        ],
      );
    } else if (isDownloaded) {
      // Загружено
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      );
    } else {
      // Не загружено
      trailing = IconButton(
        icon: const Icon(Icons.download_for_offline),
        tooltip: 'Загрузить',
        onPressed: () {
          ref
              .read(directDownloadServiceProvider.notifier)
              .startDownload(city.slug);
        },
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDownloaded
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.accentPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDownloaded ? Icons.offline_pin : Icons.location_city,
              color: isDownloaded ? AppColors.success : AppColors.accentPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.nameRu,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasFailed) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatError(status?.error),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ] else if (isDownloaded) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Загружено',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _getStageText(DirectDownloadStage stage, int downloaded, int total) {
    switch (stage) {
      case DirectDownloadStage.fetchingManifest:
        return 'Подготовка...';
      case DirectDownloadStage.downloading:
        return '$downloaded / $total';
      case DirectDownloadStage.completed:
        return 'Готово';
      case DirectDownloadStage.failed:
        return 'Ошибка';
      default:
        return '';
    }
  }

  String _formatError(String? error) {
    if (error == null) return 'Неизвестная ошибка';
    if (error.contains('SocketException') || error.contains('Connection')) {
      return 'Нет подключения к интернету';
    }
    if (error.contains('404')) {
      return 'Данные города недоступны';
    }
    if (error.length > 50) {
      return '${error.substring(0, 50)}...';
    }
    return error;
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить загрузку?'),
        content: Text('Удалить оффлайн данные для ${city.nameRu}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              ref
                  .read(directDownloadServiceProvider.notifier)
                  .deleteBundle(city.slug);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
