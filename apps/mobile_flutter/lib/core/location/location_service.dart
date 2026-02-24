import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';

part 'location_service.g.dart';

class LocationService {
  final Ref _ref;
  final StreamController<Position> _positionController =
      StreamController.broadcast();
  StreamSubscription<Position>? _positionSubscription;

  Stream<Position> get positionStream => _positionController.stream;

  LocationService(this._ref) {
    _init();
  }

  void _init() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Load background setting
    final settings = await _ref.read(settingsRepositoryProvider.future);
    final bgEnabled = settings.getBackgroundLocationEnabled();
    _startPositionStream(bgEnabled);
  }

  void _startPositionStream(bool backgroundEnabled) {
    _positionSubscription?.cancel();

    LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
        foregroundNotificationConfig: backgroundEnabled
            ? const ForegroundNotificationConfig(
                notificationTitle: "????????",
                notificationText: "???????????? ????????",
                notificationIcon: AndroidResource(name: 'ic_launcher'),
              )
            : null,
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: !backgroundEnabled,
        showBackgroundLocationIndicator: backgroundEnabled,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      );
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _positionController.add(position);
    });
  }

  Future<void> updateBackgroundTracking(bool enable) async {
    final settings = await _ref.read(settingsRepositoryProvider.future);
    await settings.setBackgroundLocationEnabled(enable);
    _startPositionStream(enable);
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(
      double startLat, double startLon, double endLat, double endLon) {
    const Distance distance = Distance();
    return distance.as(
        LengthUnit.Meter, LatLng(startLat, startLon), LatLng(endLat, endLon));
  }
}

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  return LocationService(ref);
}

@riverpod
Stream<Position> locationStream(Ref ref) {
  final service = ref.watch(locationServiceProvider);
  return service.positionStream;
}
