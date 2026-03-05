import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/core/api/device_id_provider.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';
import 'package:mobile_flutter/design_system/tokens/spacing.dart';
import 'package:mobile_flutter/design_system/tokens/motion.dart';
import 'package:mobile_flutter/design_system/styles/gradients.dart';
import 'package:mobile_flutter/design_system/styles/glass.dart';
import 'package:flutter/services.dart';

class TourModeScreen extends ConsumerStatefulWidget {
  const TourModeScreen({super.key});

  @override
  ConsumerState<TourModeScreen> createState() => _TourModeScreenState();
}

class _TourModeScreenState extends ConsumerState<TourModeScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _shouldFollowUser = true;

  @override
  void initState() {
    super.initState();
    // Start listening to location updates
    ref.read(locationServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourModeServiceProvider);

    // Redirect if no tour is active (safety check)
    if (!tourState.isActive || tourState.activeTour == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeTour = tourState.activeTour!;
    final items = activeTour.items ?? [];

    // Filter only valid POIs for the map
    final validPois = items.map((i) => i.poi).whereType<Poi>().toList();
    final points = validPois.map((p) => LatLng(p.lat, p.lon)).toList();

    final userPosition = ref.watch(locationStreamProvider).value;

    // Auto-center Logic
    if (_shouldFollowUser && userPosition != null) {
      _mapController.move(LatLng(userPosition.latitude, userPosition.longitude),
          _mapController.camera.zoom);
    }

    // Path to next point
    final List<LatLng> nextPointPath = [];
    if (userPosition != null && tourState.currentPoi != null) {
      nextPointPath.add(LatLng(userPosition.latitude, userPosition.longitude));
      nextPointPath
          .add(LatLng(tourState.currentPoi!.lat, tourState.currentPoi!.lon));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  points.isNotEmpty ? points.first : const LatLng(59.93, 30.33),
              initialZoom: 16.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _shouldFollowUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.audiogid.app',
              ),
              // Full Tour Path
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: Colors.blueAccent.withOpacity(0.5),
                    strokeWidth: 4.0,
                  ),
                  // Path to next point (High visibility)
                  if (nextPointPath.isNotEmpty)
                    Polyline(
                      points: nextPointPath,
                      color: Colors.orange,
                      strokeWidth: 3.0,
                      pattern: const StrokePattern.dotted(),
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User Marker
                  if (userPosition != null)
                    Marker(
                      point:
                          LatLng(userPosition.latitude, userPosition.longitude),
                      width: 50,
                      height: 50,
                      child: _UserMarker(heading: userPosition.heading),
                    ),

                  // POI Markers
                  ...validPois.asMap().entries.map((entry) {
                    final index = entry.key;
                    final poi = entry.value;
                    final isCurrent = index == tourState.currentStepIndex;
                    final isPassed = index < tourState.currentStepIndex;

                    return Marker(
                      point: LatLng(poi.lat, poi.lon),
                      width: 60,
                      height: 60,
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 2)
                                ]),
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            color: isCurrent
                                ? Colors.redAccent
                                : (isPassed ? Colors.grey : Colors.blue),
                            size: isCurrent ? 40 : 30,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Re-center button
          if (!_shouldFollowUser)
            Positioned(
              right: AppSpacing.md,
              bottom: 280,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _shouldFollowUser = true);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.fab),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      borderRadius: BorderRadius.circular(AppRadius.fab),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

          // Top Info Card
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              decoration: GlassDecoration.card(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tourState.currentPoi?.titleRu ?? 'Конец маршрута',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (tourState.distanceToNextPoi != null)
                          Row(
                            children: [
                              Text(
                                '${tourState.distanceToNextPoi!.toInt()} м',
                                style: const TextStyle(
                                  color: AppColors.accentPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (tourState.etaSeconds != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  ' • ${_formatDuration(tourState.etaSeconds!)}',
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // AutoPlay Toggle
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(tourModeServiceProvider.notifier)
                            .toggleAutoPlay();
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tourState.isAutoPlayEnabled
                              ? AppColors.accentPrimary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          tourState.isAutoPlayEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: tourState.isAutoPlayEnabled
                              ? AppColors.accentPrimary
                              : AppColors.textTertiary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Off-Route Banner
          if (tourState.isOffRoute)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        "Вы ушли с маршрута",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _shouldFollowUser = true);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      child: const Text(
                        "ПОКАЗАТЬ",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: _TourControls(
              state: tourState,
              totalSteps: validPois.length,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '< 1 мин';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes мин';
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    return '$hours ч $mins мин';
  }
}

class _UserMarker extends StatelessWidget {
  final double heading;

  const _UserMarker({this.heading = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _degreesToRadians(heading),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              // Direction Arrow
              const Icon(Icons.arrow_upward, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159 / 180.0);
  }
}

class _TourControls extends ConsumerWidget {
  final TourModeState state;
  final int totalSteps;

  const _TourControls({required this.state, required this.totalSteps});

  Future<void> _showRatingDialog(
      BuildContext context, WidgetRef ref, String tourId) async {
    int selectedRating = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Как вам прогулка?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Оцените тур, чтобы помочь другим пользователям'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => selectedRating = starIndex),
                    icon: Icon(
                      starIndex <= selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              if (selectedRating > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getRatingText(selectedRating),
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Пропустить'),
            ),
            FilledButton(
              onPressed: selectedRating > 0
                  ? () async {
                      Navigator.pop(ctx);
                      await _submitRating(ref, tourId, selectedRating);
                    }
                  : null,
              child: const Text('Оценить'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Очень плохо';
      case 2:
        return 'Плохо';
      case 3:
        return 'Нормально';
      case 4:
        return 'Хорошо';
      case 5:
        return 'Отлично!';
      default:
        return '';
    }
  }

  Future<void> _submitRating(WidgetRef ref, String tourId, int rating) async {
    try {
      final dio = Dio();
      final config = ref.read(appConfigProvider);
      final deviceId = await ref.read(deviceIdProvider.future);

      await dio.post(
        '${config.apiBaseUrl}/public/tours/$tourId/rate',
        data: {
          'rating': rating,
          'device_anon_id': deviceId,
        },
      );
    } catch (e) {
      print('Failed to submit rating: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          final playbackState = snapshot.data;
          final isPlaying = playbackState?.playing ?? false;
          final processingState = playbackState?.processingState;
          final isBuffering = processingState == AudioProcessingState.buffering;

          return Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: GlassDecoration.card(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: LinearProgressIndicator(
                    value: totalSteps > 0
                        ? ((state.currentStepIndex + 1) / totalSteps)
                        : 0,
                    minHeight: 4,
                    backgroundColor: AppColors.bgPrimary,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Локация ${state.currentStepIndex + 1} из $totalSteps',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: state.currentStepIndex > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(tourModeServiceProvider.notifier)
                                    .prevStep();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: state.currentStepIndex > 0
                                ? AppColors.bgPrimary
                                : AppColors.bgPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.skip_previous_rounded,
                            size: 28,
                            color: state.currentStepIndex > 0
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (isPlaying) {
                            audioHandler.pause();
                          } else {
                            audioHandler.play();
                          }
                        },
                        borderRadius: BorderRadius.circular(AppRadius.fab),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryButton,
                            borderRadius: BorderRadius.circular(AppRadius.fab),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPrimary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isBuffering
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: state.currentStepIndex < totalSteps - 1
                            ? () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(tourModeServiceProvider.notifier)
                                    .nextStep();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: state.currentStepIndex < totalSteps - 1
                                ? AppColors.bgPrimary
                                : AppColors.bgPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.skip_next_rounded,
                            size: 28,
                            color: state.currentStepIndex < totalSteps - 1
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final tourId = state.activeTour?.id;
                    ref.read(tourModeServiceProvider.notifier).stopTour();

                    // Show rating dialog
                    if (tourId != null && context.mounted) {
                      await _showRatingDialog(context, ref, tourId);
                    }

                    if (context.mounted) {
                      if (context.canPop()) context.pop();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text(
                    'Завершить прогулку',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
