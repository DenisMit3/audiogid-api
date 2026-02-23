import 'package:mobile_flutter/presentation/screens/sos_screen.dart';
import 'package:mobile_flutter/presentation/screens/trusted_contacts_screen.dart';
import 'package:mobile_flutter/presentation/screens/shared_location_screen.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/screens/city_select_screen.dart';
import 'package:mobile_flutter/presentation/screens/welcome_screen.dart';
import 'package:mobile_flutter/presentation/screens/onboarding_screen.dart';
import 'package:mobile_flutter/presentation/screens/nearby_screen.dart';
import 'package:mobile_flutter/presentation/screens/tours_list_screen.dart';
import 'package:mobile_flutter/presentation/screens/tour_detail_screen.dart';
import 'package:mobile_flutter/presentation/screens/catalog_screen.dart';
import 'package:mobile_flutter/presentation/screens/poi_detail_screen.dart';
import 'package:mobile_flutter/presentation/screens/favorites_screen.dart';
import 'package:mobile_flutter/presentation/screens/main_shell.dart';
import 'package:mobile_flutter/presentation/screens/audio_player_screen.dart';
import 'package:mobile_flutter/presentation/screens/offline/offline_manager_screen.dart';
import 'package:mobile_flutter/presentation/screens/tour_mode_screen.dart';
import 'package:mobile_flutter/presentation/screens/qr_scanner_screen.dart';
import 'package:mobile_flutter/presentation/screens/login_screen.dart';
import 'package:mobile_flutter/presentation/screens/itinerary_screen.dart';
import 'package:mobile_flutter/presentation/screens/itinerary_create_screen.dart';
import 'package:mobile_flutter/presentation/screens/itinerary_viewer_screen.dart';
import 'package:mobile_flutter/presentation/screens/free_walking_mode/free_walking_mode_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/analytics/analytics_observer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final selectedCityAsync = ref.watch(selectedCityProvider);
  final onboardingCompletedAsync = ref.watch(onboardingCompletedProvider);

  final analyticsObserver = AnalyticsObserver(ref);

  return GoRouter(
    initialLocation: '/',
    observers: [analyticsObserver],
    redirect: (context, state) {
      // Ждем загрузки данных
      if (selectedCityAsync.isLoading || onboardingCompletedAsync.isLoading) {
        return null;
      }

      final selectedCity = selectedCityAsync.value;
      final onboardingCompleted = onboardingCompletedAsync.value ?? false;
      final currentPath = state.matchedLocation;

      // Список путей, которые не требуют редиректа
      final welcomePaths = ['/welcome', '/onboarding', '/city-select'];
      final isOnWelcomePath = welcomePaths.contains(currentPath);

      // 1. Если onboarding не пройден - показываем welcome
      if (!onboardingCompleted) {
        if (currentPath != '/welcome' && currentPath != '/onboarding') {
          return '/welcome';
        }
        return null;
      }

      // 2. Если onboarding пройден, но город не выбран - показываем выбор города
      if (selectedCity == null) {
        if (currentPath != '/city-select') {
          return '/city-select';
        }
        return null;
      }

      // 3. Если все настроено и пользователь на welcome/onboarding/city-select - редирект на главную
      if (isOnWelcomePath) {
        return '/';
      }

      return null;
    },
    routes: [
      // Welcome и Onboarding экраны
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/city-select',
        builder: (context, state) => const CitySelectScreen(),
      ),
      // Legacy route для совместимости
      GoRoute(
        path: '/select-city',
        redirect: (context, state) => '/city-select',
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ToursListScreen(),
          ),
          GoRoute(
            path: '/nearby',
            builder: (context, state) => const NearbyScreen(),
          ),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tour/:id',
        builder: (context, state) => TourDetailScreen(
          tourId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/poi/:id',
        builder: (context, state) => PoiDetailScreen(
          poiId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const AudioPlayerScreen(),
      ),
      GoRoute(
        path: '/offline-manager',
        builder: (context, state) => const OfflineManagerScreen(),
      ),
      GoRoute(
        path: '/tour_mode',
        builder: (context, state) => const TourModeScreen(),
      ),
      GoRoute(
        path: '/qr_scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/itinerary',
        builder: (context, state) => const ItineraryScreen(),
      ),
      GoRoute(
        path: '/itinerary/create',
        builder: (context, state) => const ItineraryCreateScreen(),
      ),
      GoRoute(
        path: '/itinerary/view/:id',
        builder: (context, state) => ItineraryViewerScreen(itineraryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/free_walking',
        builder: (context, state) => const FreeWalkingModeScreen(),
      ),
      GoRoute(
        path: '/sos',
        builder: (context, state) => const SosScreen(),
      ),
      GoRoute(
        path: '/trusted_contacts',
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: '/share_trip',
        name: 'share_trip',
        builder: (context, state) {
             final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '');
             final lon = double.tryParse(state.uri.queryParameters['lon'] ?? '');
             final time = state.uri.queryParameters['time'];
             if (lat != null && lon != null) {
                 return SharedLocationScreen(lat: lat, lon: lon, time: time);
             }
             return const Scaffold(body: Center(child: Text("Invalid Link")));
        },
      ),

      // Deep Link Redirects
      GoRoute(
        path: '/dl/tour/:id',
        redirect: (context, state) => '/tour/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/dl/poi/:id',
        redirect: (context, state) => '/poi/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/dl/city/:slug',
        redirect: (context, state) => '/catalog?city=${state.pathParameters['slug']}',
      ),
      GoRoute(
        path: '/dl/itinerary/:id',
        redirect: (context, state) => '/itinerary/view/${state.pathParameters['id']}',
      ),
    ],
  );
}
