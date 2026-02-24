import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return AnalyticsService(
    ref.watch(appDatabaseProvider),
    config.apiBaseUrl,
  );
}

class AnalyticsService {
  final AppDatabase _db;
  final String _apiBaseUrl;
  final Dio _dio;

  Timer? _timer;
  bool _isFlushing = false;

  AnalyticsService(this._db, this._apiBaseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: _apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _init();
  }

  void _init() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _flush());
    // Try flush on startup
    _scheduleFlush();
  }

  Future<void> logEvent(String eventType,
      [Map<String, dynamic>? payload]) async {
    // Persist to DB for Backend
    try {
      final id = const Uuid().v4();
      await _db.into(_db.analyticsPendingEvents).insert(
            AnalyticsPendingEventsCompanion.insert(
              id: id,
              eventType: eventType,
              payloadJson: Value(payload != null ? jsonEncode(payload) : null),
              createdAt: Value(DateTime.now()),
            ),
          );
    } catch (e) {
      debugPrint('Failed to persist analytics event: $e');
    }
  }

  Future<void> _flush() async {
    if (_isFlushing) return;
    _isFlushing = true;

    try {
      // 1. Get events
      final events = await (_db.select(_db.analyticsPendingEvents)
            ..limit(50)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

      if (events.isEmpty) return;

      // 2. Prepare request
      final prefs = await SharedPreferences.getInstance();
      var anonId = prefs.getString('device_anon_id');
      if (anonId == null) {
        anonId = const Uuid().v4();
        await prefs.setString('device_anon_id', anonId);
      }

      // 3. Prepare events payload for API
      final eventsPayload = events
          .map((e) => {
                'event_id': e.id,
                'event_type': e.eventType,
                'ts': e.createdAt.toUtc().toIso8601String(),
                'payload':
                    e.payloadJson != null ? jsonDecode(e.payloadJson!) : null,
              })
          .toList();

      // 4. Send to API
      final response = await _dio.post(
        '/analytics/events',
        data: {
          'anon_id': anonId,
          'events': eventsPayload,
        },
      );

      // 5. If successful, delete sent events
      if (response.statusCode == 202 || response.statusCode == 200) {
        await (_db.delete(_db.analyticsPendingEvents)
              ..where((t) => t.id.isIn(events.map((e) => e.id))))
            .go();
        debugPrint(
            'Analytics flush: ${events.length} events sent successfully');
      }
    } catch (e) {
      debugPrint('Analytics Sync Failed: $e');

      // Clean up old events to prevent DB bloat (older than 7 days)
      try {
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        await (_db.delete(_db.analyticsPendingEvents)
              ..where((t) => t.createdAt.isSmallerThanValue(cutoff)))
            .go();
      } catch (_) {}
    } finally {
      _isFlushing = false;
    }
  }

  void _scheduleFlush() {
    Future.delayed(const Duration(seconds: 5), () {
      _flush();
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  // ============== CONVENIENCE METHODS ==============

  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }

  Future<void> logTourStart(String tourId) async {
    await logEvent('tour_start', {'tour_id': tourId});
  }

  Future<void> logTourComplete(String tourId) async {
    await logEvent('tour_complete', {'tour_id': tourId});
  }

  Future<void> logPoiView(String poiId) async {
    await logEvent('poi_view', {'poi_id': poiId});
  }

  Future<void> logAudioPlay(String poiId, String narrationId) async {
    await logEvent(
        'audio_play', {'poi_id': poiId, 'narration_id': narrationId});
  }

  Future<void> logPurchase(String productId, double price) async {
    await logEvent('purchase', {'product_id': productId, 'price': price});
  }

  Future<void> logSearch(String query) async {
    await logEvent('search', {'query': query});
  }

  Future<void> logError(String errorType, String message) async {
    await logEvent('error', {'error_type': errorType, 'message': message});
  }
}
