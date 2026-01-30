import 'package:mobile_flutter/domain/repositories/city_repository.dart';
import 'package:mobile_flutter/domain/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/repositories/tour_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

class SyncService {
  final CityRepository _cityRepository;
  final TourRepository _tourRepository;
  final EntitlementRepository _entitlementRepository;
  final PoiRepository _poiRepository;

  SyncService(
    this._cityRepository,
    this._tourRepository,
    this._entitlementRepository,
    this._poiRepository,
  );

  Future<void> syncAll(String? citySlug) async {
    final futures = <Future>[
      _cityRepository.syncCities(),
      _entitlementRepository.syncGrants(),
    ];

    if (citySlug != null) {
      futures.add(_tourRepository.syncTours(citySlug));
      futures.add(_poiRepository.syncPoisForCity(citySlug));
    }

    await Future.wait(futures);
  }
}

@riverpod
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    ref.watch(cityRepositoryProvider),
    ref.watch(tourRepositoryProvider),
    ref.watch(entitlementRepositoryProvider),
    ref.watch(poiRepositoryProvider),
  );
}
