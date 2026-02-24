import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_flutter/presentation/screens/poi_detail_screen.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/data/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/domain/entities/city.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

// Mocks
class MockPoiRepository extends Mock implements PoiRepository {}

class MockEntitlementRepository extends Mock implements EntitlementRepository {}

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockPoiRepository mockPoiRepository;
  late MockEntitlementRepository mockEntitlementRepository;
  late MockAudioPlayerService mockAudioPlayerService;

  setUp(() {
    mockPoiRepository = MockPoiRepository();
    mockEntitlementRepository = MockEntitlementRepository();
    mockAudioPlayerService = MockAudioPlayerService();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        poiRepositoryProvider.overrideWithValue(mockPoiRepository),
        // entitlementRepositoryProvider only provides methods, entitlementGrantsProvider provides state
        entitlementGrantsProvider.overrideWith((ref) => Stream.value([])),
        audioPlayerServiceProvider.overrideWithValue(mockAudioPlayerService),
        selectedCityProvider.overrideWith((ref) => Stream.value(City(
            id: '1',
            slug: 'kaliningrad',
            nameRu: 'Kgd',
            isActive: true,
            updatedAt: DateTime.now()))),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PoiDetailScreen(poiId: 'test_poi'),
      ),
    );
  }

  testWidgets('PoiDetailScreen displays POI details', (tester) async {
    final poi = Poi(
      id: 'test_poi',
      citySlug: 'kaliningrad',
      titleRu: 'Test POI Title',
      descriptionRu: 'Test Description',
      lat: 0,
      lon: 0,
      hasAccess: true,
      narrations: [],
      media: [],
      sources: [],
    );

    when(() => mockPoiRepository.watchPoi('test_poi'))
        .thenAnswer((_) => Stream.value(poi));

    when(() => mockPoiRepository.syncPoi(any(), any()))
        .thenAnswer((_) async {});

    await mockNetworkImages(() async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Test POI Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });
  });

  testWidgets('PoiDetailScreen handles error state', (tester) async {
    when(() => mockPoiRepository.watchPoi('test_poi'))
        .thenAnswer((_) => Stream.error('Network Error'));

    when(() => mockPoiRepository.syncPoi(any(), any()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.textContaining('Network Error'), findsOneWidget);
  });
}
