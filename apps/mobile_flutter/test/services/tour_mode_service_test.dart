import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/domain/repositories/tour_repository.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_location_tracker/bg_location_tracker.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';

// Mocks
class MockAudioHandler extends Mock implements AudiogidAudioHandler {}

class MockLocationService extends Mock implements LocationService {}

class MockTourRepository extends Mock implements TourRepository {}

class MockPoiRepository extends Mock implements PoiRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late ProviderContainer container;
  late MockAudioHandler mockAudioHandler;
  late MockLocationService mockLocationService;
  late MockTourRepository mockTourRepository;
  late MockPoiRepository mockPoiRepository;
  late MockNotificationService mockNotificationService;
  late MockSettingsRepository mockSettingsRepository;

  late StreamController<PlaybackState> playbackStateController;
  late StreamController<LocationUpdate> locationStreamController;

  setUp(() {
    mockAudioHandler = MockAudioHandler();
    mockLocationService = MockLocationService();
    mockTourRepository = MockTourRepository();
    mockPoiRepository = MockPoiRepository();
    mockNotificationService = MockNotificationService();
    mockSettingsRepository = MockSettingsRepository();

    playbackStateController = StreamController<PlaybackState>.broadcast();
    locationStreamController = StreamController<LocationUpdate>.broadcast();

    when(() => mockAudioHandler.playbackState)
        .thenAnswer((_) => playbackStateController.stream);
    when(() => mockLocationService.locationStream)
        .thenAnswer((_) => locationStreamController.stream);

    // Stubbing basics
    registerFallbackValue(const Duration());

    container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(mockAudioHandler),
        locationServiceProvider.overrideWithValue(mockLocationService),
        tourRepositoryProvider.overrideWithValue(mockTourRepository),
        poiRepositoryProvider.overrideWithValue(mockPoiRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    playbackStateController.close();
    locationStreamController.close();
  });

  group('TourModeService', () {
    test('initial state should be idle', () {
      final state = container.read(tourModeServiceProvider);
      expect(state.isActive, false);
      expect(state.status, TourModeStatus.idle);
    });

    test('should auto-advance when audio completes and auto-play is enabled',
        () async {
      // Setup
      final service = container.read(tourModeServiceProvider.notifier);

      // Initialize tour mode with a dummy tour
      final tour = Tour(id: '1', citySlug: 'city', titleRu: 'Tour', items: [
        TourItemEntity(
            id: '1',
            orderIndex: 0,
            poi: PoiEntity(
                id: 'p1', citySlug: 'c', titleRu: 'P1', lat: 0, lon: 0)),
        TourItemEntity(
            id: '2',
            orderIndex: 1,
            poi: PoiEntity(
                id: 'p2', citySlug: 'c', titleRu: 'P2', lat: 0, lon: 0)),
      ]);

      // Mock startTour dependencies
      when(() => mockSettingsRepository.saveTourProgress(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockLocationService.startTracking()).thenAnswer((_) async {});
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => null);

      service.startTour(tour);

      // Enable auto-play
      service.toggleAutoPlay(true);

      // Verify initial step
      expect(container.read(tourModeServiceProvider).currentStepIndex, 0);

      // Act: Emit completed playback state
      playbackStateController.add(PlaybackState(
        processingState: AudioProcessingState.completed,
        playing: false,
      ));

      // Wait for delay in auto-advance logic (2 seconds in impl, but we can't fast-forward time easily in unit test without fake async)
      // Since we used Future.delayed in implementation, we need to wait.
      // Ideally we'd use fake async, but let's see if we can just wait a bit longer than 2s or refactor.
      // For unit test speed, creating a long delay is bad.
      // NOTE: In the implementation I put `Future.delayed(const Duration(seconds: 2), ...)`
      // This makes unit testing slow.

      await Future.delayed(const Duration(seconds: 2, milliseconds: 100));

      // Assert
      expect(container.read(tourModeServiceProvider).currentStepIndex, 1);
    });
  });
}
