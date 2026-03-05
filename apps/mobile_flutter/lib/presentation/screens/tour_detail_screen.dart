import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/repositories/tour_repository.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/data/services/download_service.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:mobile_flutter/presentation/widgets/common/glass_widgets.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:mobile_flutter/data/services/purchase_service.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  bool _isMultiSelectMode = false;
  bool _isBuying = false;
  final Set<String> _selectedPoiIds = {};
  bool _syncTriggered = false;

  String _formatAudioDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    if (mins > 0) {
      return '$mins мин';
    }
    return '$secs сек';
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider).value;
    if (selectedCity == null) {
      return const Scaffold(backgroundColor: AppColors.bgPrimary);
    }

    final tourStream =
        ref.watch(tourRepositoryProvider).watchTour(widget.tourId);

    return StreamBuilder<Tour?>(
      stream: tourStream,
      builder: (context, snapshot) {
        if (!_syncTriggered) {
          _syncTriggered = true;
          ref
              .read(tourRepositoryProvider)
              .syncTourDetail(widget.tourId, selectedCity)
              .ignore();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentPrimary),
            ),
          );
        }

        final tour = snapshot.data;
        if (tour == null) {
          return Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.accentPrimary),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка деталей тура...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final items = tour.items ?? [];

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, tour),
              _buildStatsSection(context, tour),
              _buildDescriptionSection(context, tour),
              _buildTourTimelineSection(context, tour, items),
              _buildPoiListSection(context, tour, items),
              // Bottom padding for CTA button
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, tour),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Tour tour) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.bgPrimary,
      leading: GlassFAB(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => Navigator.of(context).pop(),
        isPrimary: false,
        size: 40,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GlassFAB(
            icon: Icons.notifications_outlined,
            onPressed: () => _showReminderDialog(context, tour),
            isPrimary: false,
            size: 40,
            tooltip: 'Напомнить о туре',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GlassFAB(
            icon: _isMultiSelectMode ? Icons.close : Icons.checklist,
            onPressed: () {
              setState(() {
                if (_isMultiSelectMode) {
                  _isMultiSelectMode = false;
                  _selectedPoiIds.clear();
                } else {
                  _isMultiSelectMode = true;
                }
              });
            },
            isPrimary: false,
            size: 40,
            tooltip: _isMultiSelectMode ? 'Отменить выбор' : 'Выбрать места',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Map preview
            Semantics(
              label: 'Карта маршрута: ${tour.titleRu}',
              image: true,
              excludeSemantics: true,
              child: _buildMapPreview(context, tour),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgPrimary.withOpacity(0.6),
                    AppColors.bgPrimary,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tour.isFree)
                    const GlassBadge(
                      text: 'Бесплатно',
                      textColor: AppColors.accentPrimary,
                    )
                  else if (tour.priceAmount != null)
                    GlassBadge(
                      text: '${tour.priceAmount?.toInt()} ₽',
                      textColor: AppColors.accentPrimary,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    tour.titleRu,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, Tour tour) {
    final items = tour.items ?? [];
    if (items.isEmpty) {
      return Container(color: AppColors.bgSecondary);
    }

    final points = <LatLng>[];
    for (var item in items) {
      if (item.poi != null) {
        points.add(LatLng(item.poi!.lat, item.poi!.lon));
      }
    }

    if (points.isEmpty) {
      return Container(color: AppColors.bgSecondary);
    }

    double latSum = 0;
    double lonSum = 0;
    for (var p in points) {
      latSum += p.latitude;
      lonSum += p.longitude;
    }
    final center = LatLng(latSum / points.length, lonSum / points.length);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        backgroundColor: AppColors.bgPrimary,
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        // Dark map tiles
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.audiogid.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              color: AppColors.accentPrimary,
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: points.asMap().entries.map((entry) {
            return Marker(
              point: entry.value,
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Tour tour) {
    final items = tour.items ?? [];
    double totalAudioSeconds = 0;
    for (final item in items) {
      if (item.poi != null && item.poi!.narrations.isNotEmpty) {
        totalAudioSeconds += item.poi!.narrations.first.durationSeconds ?? 0;
      }
    }
    final totalAudioMinutes = (totalAudioSeconds / 60).ceil();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: StatItem(
                icon: Icons.schedule,
                label: 'Время',
                value: '${tour.durationMinutes ?? 0} мин',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatItem(
                icon: Icons.straighten,
                label: 'Дистанция',
                value: '${tour.distanceKm?.toStringAsFixed(1) ?? '—'} км',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatItem(
                icon: Icons.place,
                label: 'Остановок',
                value: '${items.length}',
              ),
            ),
            if (totalAudioMinutes > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: StatItem(
                  icon: Icons.headphones,
                  label: 'Аудио',
                  value: '$totalAudioMinutes мин',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Tour tour) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Об экскурсии',
              padding: EdgeInsets.only(bottom: 12),
            ),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                tour.descriptionRu ??
                    'Этот маршрут проведет вас по самым интересным местам, раскрывая историю и культуру региона.',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourTimelineSection(
      BuildContext context, Tour tour, List<TourItemEntity> items) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    // Get current progress from settings if available
    final settingsAsync = ref.read(settingsRepositoryProvider);
    final savedProgress = settingsAsync.value?.getTourProgress();
    int currentStepIndex = -1;
    if (savedProgress != null && savedProgress['tourId'] == tour.id) {
      currentStepIndex = savedProgress['stepIndex'] as int;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Маршрут',
              padding: EdgeInsets.only(bottom: 12),
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _TourTimeline(
                items: items,
                currentStepIndex: currentStepIndex,
                onStepTap: (index, item) {
                  HapticFeedback.lightImpact();
                  if (item.poi != null) {
                    context.push('/poi/${item.poi!.id}');
                  }
                },
                onPlayStep: (index, item) {
                  HapticFeedback.lightImpact();
                  final validItems =
                      items.where((i) => i.poi != null).toList();
                  final targetIndex = validItems.indexOf(item);
                  if (targetIndex >= 0) {
                    ref.read(audioPlayerServiceProvider).loadPlaylist(
                          tourId: tour.id,
                          items: validItems,
                          initialIndex: targetIndex,
                        );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiListSection(
      BuildContext context, Tour tour, List<TourItemEntity> items) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Маршрут',
              actionText: _isMultiSelectMode ? 'Выбрано: ${_selectedPoiIds.length}' : null,
              padding: const EdgeInsets.only(bottom: 12),
            ),
            if (items.isEmpty)
              const GlassCard(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Маршрут пуст',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final poi = item.poi;
                if (poi == null) {
                  return const SizedBox();
                }
                return _buildPoiCard(context, tour, poi, index, items);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiCard(BuildContext context, Tour tour, Poi poi, int index,
      List<TourItemEntity> items) {
    final isSelected = _selectedPoiIds.contains(poi.id);
    final hasAudio =
        poi.narrations.isNotEmpty && poi.narrations.first.durationSeconds != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundColor: isSelected
            ? AppColors.accentPrimary.withOpacity(0.1)
            : AppColors.bgSecondary,
        onTap: () {
          HapticFeedback.lightImpact();
          if (_isMultiSelectMode) {
            setState(() {
              if (isSelected) {
                _selectedPoiIds.remove(poi.id);
              } else {
                _selectedPoiIds.add(poi.id);
              }
            });
          } else {
            context.push('/poi/${poi.id}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.titleRu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            poi.descriptionRu ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (hasAudio) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.headphones,
                            size: 14,
                            color: AppColors.accentPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatAudioDuration(
                                poi.narrations.first.durationSeconds!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Actions
              if (_isMultiSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPoiIds.add(poi.id);
                      } else {
                        _selectedPoiIds.remove(poi.id);
                      }
                    });
                  },
                  activeColor: AppColors.accentPrimary,
                  checkColor: Colors.white,
                )
              else
                GlassFAB(
                  icon: Icons.play_arrow,
                  onPressed: () {
                    final validItems =
                        items.where((i) => i.poi != null).toList();
                    final item = items[index];
                    final targetIndex = validItems.indexOf(item);

                    ref.read(audioPlayerServiceProvider).loadPlaylist(
                          tourId: tour.id,
                          items: validItems,
                          initialIndex: targetIndex,
                        );
                  },
                  isPrimary: false,
                  size: 40,
                  tooltip: 'Воспроизвести',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Tour tour) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isMultiSelectMode) {
      return Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomPadding + 16,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Выбрано: ${_selectedPoiIds.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            PrimaryCTAButton(
              text: _isBuying ? 'Обработка...' : 'Купить выбранное',
              icon: _isBuying ? null : Icons.shopping_cart,
              isLoading: _isBuying,
              fullWidth: false,
              onPressed: (_selectedPoiIds.isEmpty || _isBuying)
                  ? () {}
                  : () async {
                      setState(() => _isBuying = true);
                      try {
                        await ref
                            .read(purchaseServiceProvider.notifier)
                            .buyBatch(_selectedPoiIds.toList(), []);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Покупка успешно завершена')),
                          );
                          setState(() {
                            _isMultiSelectMode = false;
                            _selectedPoiIds.clear();
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка покупки: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isBuying = false);
                      }
                    },
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomPadding + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: PrimaryCTAButton(
        text: 'НАЧАТЬ ТУР',
        icon: Icons.play_circle_filled,
        onPressed: () => _onStartTour(context, ref, tour),
      ),
    );
  }

  Future<void> _showReminderDialog(BuildContext context, Tour tour) async {
    final notificationService = ref.read(notificationServiceProvider);

    final hasPermission = await notificationService.hasNotificationPermission();
    if (!hasPermission) {
      final granted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          title: const Text(
            'Разрешить уведомления?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Для напоминаний о турах нам нужно разрешение на отправку уведомлений.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Не сейчас'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await notificationService
                    .requestPermissionWithExplanation();
                if (ctx.mounted) Navigator.pop(ctx, result);
              },
              child: const Text('Разрешить'),
            ),
          ],
        ),
      );

      if (granted != true) return;
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassDragHandle(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Напомнить о туре',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _ReminderOption(
              icon: Icons.schedule,
              title: 'Через 30 минут',
              onTap: () => Navigator.pop(ctx, const Duration(minutes: 30)),
            ),
            _ReminderOption(
              icon: Icons.schedule,
              title: 'Через 1 час',
              onTap: () => Navigator.pop(ctx, const Duration(hours: 1)),
            ),
            _ReminderOption(
              icon: Icons.schedule,
              title: 'Через 2 часа',
              onTap: () => Navigator.pop(ctx, const Duration(hours: 2)),
            ),
            _ReminderOption(
              icon: Icons.today,
              title: 'Завтра в это время',
              onTap: () => Navigator.pop(ctx, const Duration(days: 1)),
            ),
            _ReminderOption(
              icon: Icons.cancel_outlined,
              title: 'Отменить напоминание',
              isDestructive: true,
              onTap: () async {
                await notificationService.cancelTourReminder(tour.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Напоминание отменено')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await notificationService.scheduleRelativeTourReminder(
        tourId: tour.id,
        tourTitle: tour.titleRu,
        delay: result,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Напоминание установлено'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () => notificationService.cancelTourReminder(tour.id),
            ),
          ),
        );
      }
    }
  }

  Future<void> _onStartTour(
      BuildContext context, WidgetRef ref, Tour tour) async {
    int startIndex = 0;

    final settings = await ref.read(settingsRepositoryProvider.future);
    final savedProgress = settings.getTourProgress();

    if (savedProgress != null && savedProgress['tourId'] == tour.id) {
      final savedIndex = savedProgress['stepIndex'] as int;
      final itemsCount = tour.items?.length ?? 0;

      if (savedIndex > 0 && savedIndex < itemsCount) {
        final resume = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgSecondary,
            title: const Text(
              'Продолжить тур?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Вы остановились на остановке ${savedIndex + 1}. Продолжить с этого места?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Начать сначала'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Продолжить'),
              ),
            ],
          ),
        );

        if (resume == true) {
          startIndex = savedIndex;
        } else {
          await settings.clearTourProgress();
        }
      }
    }

    final downloadedCities = await ref.read(downloadedCitiesProvider.future);
    bool proceed = true;

    if (!downloadedCities.contains(tour.citySlug)) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          title: const Text(
            'Тур не загружен',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Для работы аудиогида без интернета рекомендуется загрузить данные города. Продолжить онлайн?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                context.push('/offline-manager');
              },
              child: const Text('Загрузить'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Продолжить онлайн'),
            ),
          ],
        ),
      );
      proceed = result ?? false;
    }

    if (proceed) {
      if (context.mounted) {
        ref.read(analyticsServiceProvider).logEvent('tour_started', {
          'tour_id': tour.id,
          'tour_name': tour.titleRu,
        });

        ref
            .read(tourModeServiceProvider.notifier)
            .startTour(tour, startIndex: startIndex);
        context.push('/tour_mode');
      }
    }
  }
}

class _ReminderOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ReminderOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _TourTimeline extends StatelessWidget {
  final List<TourItemEntity> items;
  final int currentStepIndex;
  final void Function(int index, TourItemEntity item) onStepTap;
  final void Function(int index, TourItemEntity item) onPlayStep;

  const _TourTimeline({
    required this.items,
    required this.currentStepIndex,
    required this.onStepTap,
    required this.onPlayStep,
  });

  @override
  Widget build(BuildContext context) {
    final validItems = items.where((i) => i.poi != null).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: validItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = validItems[index];
        final poi = item.poi!;
        final isCurrent = index == currentStepIndex;
        final isPassed = currentStepIndex >= 0 && index < currentStepIndex;
        final isNext = currentStepIndex >= 0 && index == currentStepIndex + 1;
        final hasAudio = poi.narrations.isNotEmpty &&
            poi.narrations.first.durationSeconds != null;

        return InkWell(
          onTap: () => onStepTap(index, item),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Timeline dot + line
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? AppColors.accentPrimary
                            : (isPassed
                                ? AppColors.textTertiary
                                : AppColors.glassBorder),
                        border: isNext
                            ? Border.all(
                                color: AppColors.accentPrimary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isCurrent || isNext
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (index < validItems.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: isPassed
                            ? AppColors.accentPrimary
                            : AppColors.glassBorder,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              poi.titleRu,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isCurrent || isNext
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isCurrent || isNext
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (hasAudio)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onPlayStep(index, item),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xs),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 20,
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (poi.descriptionRu != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          poi.descriptionRu!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
