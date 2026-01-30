import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/data/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';

class FreeWalkingState {
  final bool isActive;
  final bool isAutoPlayEnabled;
  final Set<String> playedPoiIds; // Session history
  final Poi? currentTarget;

  FreeWalkingState({
    this.isActive = false,
    this.isAutoPlayEnabled = true,
    this.playedPoiIds = const {},
    this.currentTarget,
  });

  FreeWalkingState copyWith({
    bool? isActive,
    bool? isAutoPlayEnabled,
    Set<String>? playedPoiIds,
    Poi? currentTarget,
  }) {
    return FreeWalkingState(
      isActive: isActive ?? this.isActive,
      isAutoPlayEnabled: isAutoPlayEnabled ?? this.isAutoPlayEnabled,
      playedPoiIds: playedPoiIds ?? this.playedPoiIds,
      currentTarget: currentTarget ?? this.currentTarget,
    );
  }
}

class FreeWalkingService extends StateNotifier<FreeWalkingState> {
  final Ref _ref;
  StreamSubscription<Position>? _positionSubscription;
  
  // Configuration
  static const double TRIGGER_RADIUS_METERS = 50.0;
  static const double CHECK_INTERVAL_METERS = 10.0;
  
  Position? _lastCheckPosition;

  FreeWalkingService(this._ref) : super(FreeWalkingState());

  void start() {
    state = state.copyWith(isActive: true);
    _listenToLocation();
  }

  void stop() {
    state = state.copyWith(isActive: false);
    _positionSubscription?.cancel();
  }
  
  void toggleAutoPlay() {
    state = state.copyWith(isAutoPlayEnabled: !state.isAutoPlayEnabled);
  }

  void _listenToLocation() {
    _positionSubscription?.cancel();
    final locationService = _ref.read(locationServiceProvider);

    _positionSubscription = locationService.positionStream.listen((pos) {
      if (!state.isActive) return;

      // Throttle checks by distance moved
      if (_lastCheckPosition != null) {
        final dist = locationService.calculateDistance(
            pos.latitude, pos.longitude,
            _lastCheckPosition!.latitude, _lastCheckPosition!.longitude
        );
        if (dist < CHECK_INTERVAL_METERS) return;
      }
      
      _lastCheckPosition = pos;
      _checkForNearbyPoi(pos);
    });
  }

  Future<void> _checkForNearbyPoi(Position pos) async {
    final poiRepo = _ref.read(poiRepositoryProvider);
    final locationService = _ref.read(locationServiceProvider);
    
    // Get candidates from local DB (efficient bounding box)
    final candidates = await poiRepo.getNearbyCandidates(pos.latitude, pos.longitude, TRIGGER_RADIUS_METERS);
    
    // Filter precisely and check history
    Poi? nearest;
    double minDistance = double.infinity;

    for (final poi in candidates) {
      if (state.playedPoiIds.contains(poi.id)) continue;
      
      final dist = locationService.calculateDistance(
          pos.latitude, pos.longitude, poi.lat, poi.lon);
          
      if (dist <= TRIGGER_RADIUS_METERS && dist < minDistance) {
        minDistance = dist;
        nearest = poi;
      }
    }

    if (nearest != null) {
      // Trigger!
      state = state.copyWith(
        playedPoiIds: {...state.playedPoiIds, nearest.id},
        currentTarget: nearest
      );

      if (state.isAutoPlayEnabled) {
          _playPoi(nearest);
      } else {
          // Send local notification
          _ref.read(notificationServiceProvider).showLocalNotification(
               id: nearest.id.hashCode,
               title: "Рядом интересное!",
               body: nearest.titleRu,
               payload: {'type': 'poi', 'id': nearest.id},
          );
      }
    }
  }

  Future<void> _playPoi(Poi poi) async {
     // Ensure full details are loaded (e.g. narrations from relation)
     // Actually loadPlaylist expects Poi entity which we have.
     // But we might need check entitlements or if narration is available?
     // AudioPlayerService handles preview/full logic.
     
     await _ref.read(audioPlayerServiceProvider).loadPlaylist(
         tourId: 'free_walking', // Pseudo ID
         pois: [poi], 
         initialIndex: 0
     );
     await _ref.read(audioPlayerServiceProvider).play();
  }
}

final freeWalkingServiceProvider = StateNotifierProvider<FreeWalkingService, FreeWalkingState>((ref) {
  return FreeWalkingService(ref);
});
