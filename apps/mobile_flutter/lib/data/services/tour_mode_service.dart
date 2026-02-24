import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tour_mode_service.g.dart';

class TourModeState {
  final Tour? activeTour;
  final int currentStepIndex;
  final double? distanceToNextPoi;
  final int? etaSeconds;
  final bool isAutoPlayEnabled;
  final bool isOffRoute;
  final bool isActive;

  // Derived getters
  Poi? get currentPoi {
    if (activeTour == null || activeTour!.items == null) return null;
    if (currentStepIndex >= activeTour!.items!.length) return null;
    return activeTour!.items![currentStepIndex].poi;
  }

  Poi? get nextPoi {
    if (activeTour == null || activeTour!.items == null) return null;
    if (currentStepIndex + 1 >= activeTour!.items!.length) return null;
    return activeTour!.items![currentStepIndex + 1].poi;
  }

  TourModeState({
    this.activeTour,
    this.currentStepIndex = 0,
    this.distanceToNextPoi,
    this.etaSeconds,
    this.isAutoPlayEnabled = true,
    this.isOffRoute = false,
    this.isActive = false,
  });

  TourModeState copyWith({
    Tour? activeTour,
    int? currentStepIndex,
    double? distanceToNextPoi,
    int? etaSeconds,
    bool? isAutoPlayEnabled,
    bool? isOffRoute,
    bool? isActive,
  }) {
    return TourModeState(
      activeTour: activeTour ?? this.activeTour,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      distanceToNextPoi: distanceToNextPoi ?? this.distanceToNextPoi,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      isAutoPlayEnabled: isAutoPlayEnabled ?? this.isAutoPlayEnabled,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      isActive: isActive ?? this.isActive,
    );
  }
}

@riverpod
class TourModeService extends _$TourModeService {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<MediaItem?>? _mediaItemSubscription;

  static const double GEOFENCE_RADIUS_METERS = 30.0;
  static const double OFF_ROUTE_THRESHOLD_METERS = 100.0;
  static const double PREF_WALKING_SPEED_M_S = 1.4; // approx 5km/h

  final Map<int, int> _itemToQueueIndex = {};
  int _queueLength = 0;

  // Internal state tracking
  String? _lastAutoPlayPoiId;
  DateTime? _lastOffRouteNotificationTime;

  @override
  TourModeState build() {
    ref.onDispose(() {
      _cancelSubscriptions();
    });
    return TourModeState();
  }

  void startTour(Tour tour, {int startIndex = 0}) {
    // Build mapping
    _itemToQueueIndex.clear();
    final validPois = <Poi>[];

    if (tour.items != null) {
      int queueIdx = 0;
      for (int i = 0; i < tour.items!.length; i++) {
        final item = tour.items![i];
        if (item.poi != null) {
          validPois.add(item.poi!);
          _itemToQueueIndex[i] = queueIdx;
          queueIdx++;
        }
      }
    }
    _queueLength = validPois.length;
    _lastAutoPlayPoiId = null;
    _lastOffRouteNotificationTime = null;

    state = TourModeState(
      activeTour: tour,
      currentStepIndex: startIndex,
      isActive: true,
      isAutoPlayEnabled: true,
    );

    _listenToLocation();
    _listenToPlayback();

    if (validPois.isNotEmpty) {
      // Find initial queue index
      final initialQueueIndex = _itemToQueueIndex[startIndex] ?? 0;

      ref.read(audioPlayerServiceProvider).loadPlaylist(
            tourId: tour.id,
            pois: validPois,
            initialIndex: initialQueueIndex,
          );
    }

    _saveProgress();
  }

  void stopTour() {
    state = TourModeState(isActive: false);
    _cancelSubscriptions();
    ref.read(audioPlayerServiceProvider).stop();
    ref.read(settingsRepositoryProvider).value?.clearTourProgress();
  }

  void _cancelSubscriptions() {
    _positionSubscription?.cancel();
    _playbackSubscription?.cancel();
    _mediaItemSubscription?.cancel();
  }

  void toggleAutoPlay() {
    bool enabled = !state.isAutoPlayEnabled;
    state = state.copyWith(isAutoPlayEnabled: enabled);
    _saveProgress();

    // If enabling while inside geo-fence, try playing immediately
    if (enabled && state.activeTour != null) {
      if (state.distanceToNextPoi != null &&
          state.distanceToNextPoi! <= GEOFENCE_RADIUS_METERS) {
        _triggerAutoPlayIfNeeded();
      }
    }
  }

  void nextStep() {
    if (!state.isActive || state.activeTour == null) return;
    final items = state.activeTour!.items;
    if (items == null) return;

    if (state.currentStepIndex < items.length - 1) {
      final newIndex = state.currentStepIndex + 1;
      state = state.copyWith(currentStepIndex: newIndex);
      _saveProgress();
      _skipToCorrectQueueItem(newIndex);
    } else {
      // Tour completed
      stopTour();
    }
  }

  void prevStep() {
    if (!state.isActive) return;
    if (state.currentStepIndex > 0) {
      final newIndex = state.currentStepIndex - 1;
      state = state.copyWith(currentStepIndex: newIndex);
      _saveProgress();
      _skipToCorrectQueueItem(newIndex);
    }
  }

  void _skipToCorrectQueueItem(int stepIndex) {
    if (_itemToQueueIndex.containsKey(stepIndex)) {
      final queueIndex = _itemToQueueIndex[stepIndex]!;
      if (queueIndex < _queueLength) {
        ref.read(audioHandlerProvider).skipToQueueItem(queueIndex);
      }
    }
  }

  void _listenToLocation() {
    final locationService = ref.read(locationServiceProvider);
    _positionSubscription?.cancel();
    _positionSubscription = locationService.positionStream.listen((position) {
      if (!state.isActive || state.currentPoi == null) return;

      final target = state.currentPoi!;
      final distance = locationService.calculateDistance(
        position.latitude,
        position.longitude,
        target.lat,
        target.lon,
      );

      // ETA Calculation
      // Use current speed if valid (and moving), else fallback to walking speed
      final speed = (position.speedAccuracy > 0 || position.speed > 0.5)
          ? (position.speed > 0.1 ? position.speed : PREF_WALKING_SPEED_M_S)
          : PREF_WALKING_SPEED_M_S;

      // Apply Urban Tortuosity Factor (approx 1.3)
      final adjustedDistance = distance * 1.3;
      final eta = adjustedDistance / speed;

      // Off-route logic
      final isOffRoute = distance > OFF_ROUTE_THRESHOLD_METERS;
      if (isOffRoute && !state.isOffRoute) {
        // Just transitioned to off-route
        _handleOffRoute();
      }

      state = state.copyWith(
        distanceToNextPoi: distance,
        etaSeconds: eta.round(),
        isOffRoute: isOffRoute,
      );

      if (state.isAutoPlayEnabled && distance <= GEOFENCE_RADIUS_METERS) {
        _triggerAutoPlayIfNeeded();
      }
    });
  }

  void _handleOffRoute() {
    final now = DateTime.now();
    if (_lastOffRouteNotificationTime == null ||
        now.difference(_lastOffRouteNotificationTime!) >
            const Duration(minutes: 5)) {
      _lastOffRouteNotificationTime = now;
      ref.read(notificationServiceProvider).showNotification(
            id: 12345, // Fixed ID to avoid spamming multiple notifications
            title: 'Вы отклонились от маршрута',
            body:
                'Вернитесь к точке ${state.currentPoi?.titleRu ?? "маршрута"}',
            channelId: NotificationChannels.tourReminders,
            payload: 'tour:${state.activeTour?.id}',
          );
    }
  }

  void _triggerAutoPlayIfNeeded() {
    if (state.currentPoi == null) return;

    // Prevent re-triggering for the same POI
    if (_lastAutoPlayPoiId == state.currentPoi!.id) return;

    final audioHandler = ref.read(audioHandlerProvider);
    final playbackState = audioHandler.playbackState.value;

    // Only play if not already playing or processing
    final notPlaying = !playbackState.playing &&
        playbackState.processingState != AudioProcessingState.buffering;

    if (notPlaying) {
      audioHandler.play();
      _lastAutoPlayPoiId = state.currentPoi!.id;
    }
  }

  void _listenToPlayback() {
    final audioHandler = ref.read(audioHandlerProvider);

    _mediaItemSubscription?.cancel();
    _mediaItemSubscription = audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null || state.activeTour == null) return;

      final poiId = mediaItem.extras?['poiId'];
      if (poiId != null) {
        final items = state.activeTour!.items;
        if (items != null) {
          final index = items.indexWhere((item) => item.poi?.id == poiId);
          if (index != -1 && index != state.currentStepIndex) {
            // Update state to match currently playing audio (user manual skip)
            state = state.copyWith(currentStepIndex: index);
            _lastAutoPlayPoiId = poiId; // Sync tracking
            _saveProgress();
          }
        }
      }
    });

    _playbackSubscription?.cancel();
    _playbackSubscription = audioHandler.playbackState.listen((playbackState) {
      if (playbackState.processingState == AudioProcessingState.completed) {
        if (state.isAutoPlayEnabled) {
          // Auto-advance after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (state.isActive) nextStep();
          });
        }
      }
    });
  }

  Future<void> _saveProgress() async {
    if (state.activeTour == null) return;
    final settings = ref.read(settingsRepositoryProvider).value;
    if (settings != null) {
      await settings.saveTourProgress(state.activeTour!.id,
          state.currentStepIndex, state.isAutoPlayEnabled);
    }
  }
}
