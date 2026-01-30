import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/screens/city_select_screen.dart';
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
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final selectedCityAsync = ref.watch(selectedCityProvider);

  return GoRouter(
    initialLocation: '/',
    observers: [routeObserver],
    redirect: (context, state) {
      if (selectedCityAsync.isLoading) return null;

      final selectedCity = selectedCityAsync.valueOrNull;
      final isSelecting = state.matchedLocation == '/select-city';

      if (selectedCity == null) {
        if (!isSelecting) return '/select-city';
      } else {
        if (isSelecting) return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/select-city',
        builder: (context, state) => const CitySelectScreen(),
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
    ],
  );
}
