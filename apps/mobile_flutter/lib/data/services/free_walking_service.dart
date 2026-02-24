import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/data/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'free_walking_service.g.dart';

class FreeWalkingState {
  final bool isActive;
  final bool isAutoPlayEnabled;
  final Set<String> playedPoiIds; // Session history
  final Poi? currentTarget;
  final double activationRadius;
  final int cooldownMinutes;
  final List<Poi> recentActivity;
  final String? statusMessage;

  FreeWalkingState({
    this.isActive = false,
    this.isAutoPlayEnabled = true,
    this.playedPoiIds = const {},
    this.currentTarget,
    this.activationRadius = 50.0,
    this.cooldownMinutes = 15,
    this.recentActivity = const [],
    this.statusMessage,
  });

  FreeWalkingState copyWith({
    bool? isActive,
    bool? isAutoPlayEnabled,
    Set<String>? playedPoiIds,
    Poi? currentTarget,
    double? activationRadius,
    int? cooldownMinutes,
    List<Poi>? recentActivity,
    String? statusMessage,
  }) {
    return FreeWalkingState(
      isActive: isActive ?? this.isActive,
      isAutoPlayEnabled: isAutoPlayEnabled ?? this.isAutoPlayEnabled,
      playedPoiIds: playedPoiIds ?? this.playedPoiIds,
      currentTarget: currentTarget ?? this.currentTarget,
      activationRadius: activationRadius ?? this.activationRadius,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      recentActivity: recentActivity ?? this.recentActivity,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class FreeWalkingService extends _$FreeWalkingService {
  StreamSubscription<Position>? _positionSubscription;

  // Configuration
  static const double CHECK_INTERVAL_METERS = 10.0;

  final Map<String, DateTime> _lastPlayedMap = {};

  Position? _lastCheckPosition;

  @override
  FreeWalkingState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });
    return FreeWalkingState();
  }

  void start() {
    ref.read(locationServiceProvider).updateBackgroundTracking(true);
    state = state.copyWith(isActive: true, statusMessage: 'Scanning...');
    _listenToLocation();
  }

  void stop() {
    ref.read(locationServiceProvider).updateBackgroundTracking(false);
    state = state.copyWith(isActive: false, statusMessage: 'Paused');
    _positionSubscription?.cancel();
  }

  void toggleAutoPlay() {
    state = state.copyWith(isAutoPlayEnabled: !state.isAutoPlayEnabled);
  }

  void updateSettings({double? radius, int? cooldown}) {
    state = state.copyWith(
      activationRadius: radius,
      cooldownMinutes: cooldown,
    );
  }

  void _listenToLocation() {
    _positionSubscription?.cancel();
    final locationService = ref.read(locationServiceProvider);

    _positionSubscription = locationService.positionStream.listen((pos) {
      if (!state.isActive) return;

      // Throttle checks by distance moved
      if (_lastCheckPosition != null) {
        final dist = locationService.calculateDistance(
            pos.latitude,
            pos.longitude,
            _lastCheckPosition!.latitude,
            _lastCheckPosition!.longitude);
        if (dist < CHECK_INTERVAL_METERS) return;
      }

      _lastCheckPosition = pos;
      _checkForNearbyPoi(pos);
    });
  }

  Future<void> _checkForNearbyPoi(Position pos) async {
    final poiRepo = ref.read(poiRepositoryProvider);
    final locationService = ref.read(locationServiceProvider);

    // Get candidates from local DB (efficient bounding box)
    final fetchRadius = state.activationRadius * 1.5;
    final candidates = await poiRepo.getNearbyCandidates(
        pos.latitude, pos.longitude, fetchRadius);

    // Filter precisely and check history
    Poi? nearest;
    double minDistance = double.infinity;
    final now = DateTime.now();

    for (final poi in candidates) {
      if (state.playedPoiIds.contains(poi.id)) continue;

      // Cooldown check
      if (_lastPlayedMap.containsKey(poi.id)) {
        final lastPlayed = _lastPlayedMap[poi.id]!;
        if (now.difference(lastPlayed).inMinutes < state.cooldownMinutes) {
          continue;
        }
      }

      final dist = locationService.calculateDistance(
          pos.latitude, pos.longitude, poi.lat, poi.lon);

      if (dist <= state.activationRadius && dist < minDistance) {
        minDistance = dist;
        nearest = poi;
      }
    }

    if (nearest != null) {
      // Trigger!
      _lastPlayedMap[nearest.id] = now;

      final newHistory = [nearest, ...state.recentActivity];
      if (newHistory.length > 10) newHistory.removeLast();

      state = state.copyWith(
        playedPoiIds: {...state.playedPoiIds, nearest.id},
        currentTarget: nearest,
        recentActivity: newHistory,
        statusMessage: 'Found: ${nearest.titleRu}',
      );

      if (state.isAutoPlayEnabled) {
        _playPoi(nearest);
      } else {
        // Send local notification
        ref.read(notificationServiceProvider).showLocalNotification(
          id: nearest.id.hashCode,
          title: "Рядом интересное!",
          body: nearest.titleRu,
          payload: {'type': 'poi', 'id': nearest.id},
        );
      }
    }
  }

  Future<void> _playPoi(Poi poi) async {
    await ref.read(audioPlayerServiceProvider).loadPlaylist(
        tourId: 'free_walking', // Pseudo ID
        pois: [poi],
        initialIndex: 0);
    await ref.read(audioPlayerServiceProvider).play();
  }
}
