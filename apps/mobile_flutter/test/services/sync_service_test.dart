import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/data/services/sync_service.dart';
import 'package:mobile_flutter/domain/repositories/city_repository.dart';
import 'package:mobile_flutter/domain/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/repositories/tour_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([
  CityRepository,
  TourRepository,
  EntitlementRepository,
  PoiRepository,
])
void main() {
  late MockCityRepository mockCityRepository;
  late MockTourRepository mockTourRepository;
  late MockEntitlementRepository mockEntitlementRepository;
  late MockPoiRepository mockPoiRepository;
  late SyncService syncService;

  setUp(() {
    mockCityRepository = MockCityRepository();
    mockTourRepository = MockTourRepository();
    mockEntitlementRepository = MockEntitlementRepository();
    mockPoiRepository = MockPoiRepository();
    syncService = SyncService(
      mockCityRepository,
      mockTourRepository,
      mockEntitlementRepository,
      mockPoiRepository,
    );
  });

  group('SyncService', () {
    test('syncAll syncs basic data when cityId is null', () async {
      await syncService.syncAll(null);

      verify(mockCityRepository.syncCities()).called(1);
      verify(mockEntitlementRepository.syncGrants()).called(1);
      verifyNever(mockTourRepository.syncTours(any));
      verifyNever(mockPoiRepository.syncPoisForCity(any));
    });

    test('syncAll syncs all data when cityId is provided', () async {
      const citySlug = 'kaliningrad';
      await syncService.syncAll(citySlug);

      verify(mockCityRepository.syncCities()).called(1);
      verify(mockEntitlementRepository.syncGrants()).called(1);
      verify(mockTourRepository.syncTours(citySlug)).called(1);
      verify(mockPoiRepository.syncPoisForCity(citySlug)).called(1);
    });
  });
}
