import 'dart:async';
import 'dart:convert';
import 'package:api_client/api.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:built_value/json_object.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider),
  );
}

class AnalyticsService {
  final AppDatabase _db;
  final ApiClient _apiClient;
  // final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  
  Timer? _timer;
  bool _isFlushing = false;

  AnalyticsService(this._db, this._apiClient) {
    _init();
  }

  void _init() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _flush());
    // Try flush on startup
    _scheduleFlush();
  }

  Future<void> logEvent(String eventType, [Map<String, dynamic>? payload]) async {
    // 1. Log to Firebase (Removed)
    /*
    try {
        // Firebase event names must be alphanumeric + underscore
        final firebaseName = eventType.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        await _firebase.logEvent(
            name: firebaseName.substring(0, firebaseName.length > 40 ? 40 : null), // Max length
            parameters: payload,
        );
    } catch (e) {
        debugPrint('Firebase Analytics Error: $e');
    }
    */

    // 2. Persist to DB for Backend
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

    // 3. Trigger flush if needed, but we rely on timer
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

      final ingestEvents = events.map((e) {
        JsonObject? payloadObj;
        if (e.payloadJson != null) {
           try {
             payloadObj = JsonObject(jsonDecode(e.payloadJson!));
           } catch (_) {}
        }
        
        return EventIngest((b) => b
             ..eventId = e.id
             ..eventType = e.eventType
             ..ts = e.createdAt.toUtc()
             ..payload = payloadObj
        );
      }).toList();

      // 3. Send
      final api = _apiClient.getAnalyticsApi(); 
      if (api == null) {
        throw Exception('AnalyticsApi not found in ApiClient');
      }

      await api.ingestEvents(
          batchIngestReq: BatchIngestReq((b) => b
            ..anonId = anonId
            ..events.replace(ingestEvents)
          )
      );

      // 4. Delete sent events
      await (_db.delete(_db.analyticsPendingEvents)
            ..where((t) => t.id.isIn(events.map((e) => e.id))))
          .go();

      // 5. If we had 50, check for more
      if (events.length == 50) {
          _isFlushing = false; 
          _scheduleFlush(); // Schedule immediately next run
          return;
      }

    } catch (e) {
      debugPrint('Analytics Sync Failed: $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
    // await _firebase.logScreenView(screenName: screenName);
  }

  Future<void> logTourStart(String tourId) async {
    await logEvent('tour_started', {'tour_id': tourId});
  }

  Future<void> logPoiView(String poiId) async {
    await logEvent('poi_viewed', {'poi_id': poiId});
  }
  
  Future<void> logPurchase(String productId, double price, String currency) async {
    await logEvent('purchase_completed', {
      'product_id': productId,
      'value': price,
      'currency': currency,
    });
    // Firebase standard purchase
    /*
    await _firebase.logPurchase(
      currency: currency,
      value: price,
      items: [AnalyticsEventItem(itemId: productId)],
    );
    */
  }

  Future<void> logAudioPlay(String? title) async {
    await logEvent('audio_play', {'title': title});
  }

  Future<void> setUserProperty(String name, String value) async {
    // await _firebase.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String id) async {
    // await _firebase.setUserId(id: id);
  }

  Future<void> setUserCity(String citySlug) async {
    await setUserProperty('city_preference', citySlug);
  }

  Future<void> setSubscriptionStatus(String status) async {
    await setUserProperty('subscription_status', status);
  }

  void _scheduleFlush() {
      Future.delayed(const Duration(seconds: 1), _flush);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
