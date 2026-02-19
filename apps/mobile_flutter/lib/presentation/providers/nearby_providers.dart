import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/helper.dart';
import 'package:mobile_flutter/domain/repositories/helper_repository.dart';
import 'package:mobile_flutter/data/repositories/helper_repository_impl.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/data/repositories/poi_repository_impl.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';

part 'nearby_providers.g.dart';

@riverpod
HelperRepository helperRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final cityAsync = ref.watch(selectedCityProvider);
  // We unwrap asyncvalue, defaulting to null if loading/error
  final citySlug = cityAsync.value;
  return HelperRepositoryImpl(dio, citySlug);
}

@riverpod
PoiRepository poiRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(publicApiProvider);
  return PoiRepositoryImpl(db, api);
}

@riverpod
Future<List<Helper>> nearbyHelpers(Ref ref) async {
  final repo = ref.watch(helperRepositoryProvider);
  return repo.getAllHelpers();
}

@riverpod
String mapStyleUrl(Ref ref) {
  // Configurable via provider. Could verify with SettingsRepository if needed.
  // Using a demo vector style URL compliant with MapLibre
  return 'https://demotiles.maplibre.org/style.json'; 
}

@riverpod
Stream<Position> userLocationStream(Ref ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
}

@riverpod
class SelectedHelperType extends _$SelectedHelperType {
  @override
  HelperType? build() => null; 

  void select(HelperType? type) {
    state = type;
  }
}
