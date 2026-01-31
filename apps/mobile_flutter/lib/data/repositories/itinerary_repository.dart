import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'itinerary_repository.g.dart';

import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';

import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class ItineraryRepository {
  final SharedPreferences _prefs;
  final Dio _dio;
  final AppDatabase _db;
  static const _key = 'custom_itinerary_ids';

  ItineraryRepository(this._prefs, this._dio, this._db);

  List<String> getItineraryIds() {
    return _prefs.getStringList(_key) ?? [];
  }

  Future<void> addToItinerary(String id) async {
    final list = getItineraryIds();
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList(_key, list);
    }
  }

  Future<void> removeFromItinerary(String id) async {
    final list = getItineraryIds();
    list.remove(id);
    await _prefs.setStringList(_key, list);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = getItineraryIds();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _prefs.setStringList(_key, list);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  Future<Map<String, dynamic>> createItinerary({
    required String title,
    required String citySlug,
    required List<String> poiIds,
    required String deviceAnonId,
  }) async {
    final response = await _dio.post('/public/itineraries', data: {
      'title': title,
      'city_slug': citySlug,
      'poi_ids': poiIds,
      'device_anon_id': deviceAnonId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getItinerary(String id) async {
    final response = await _dio.get('/public/itineraries/$id');
    return response.data;
  }
  Future<Map<String, dynamic>> getItineraryManifest(String id) async {
    final response = await _dio.get('/public/itineraries/$id/manifest');
    return response.data;
  }

  Future<void> saveToDb(Map<String, dynamic> manifest) async {
      final tourData = manifest['tour'] as Map<String, dynamic>;
      final poisData = manifest['pois'] as List;

      final tourComp = ToursCompanion(
        id: Value(tourData['id']),
        citySlug: Value(tourData['city_slug']),
        titleRu: Value(tourData['title_ru']),
        durationMinutes: Value(tourData['duration_minutes']),
        // transportType: Value("walking"), // default
      );

      final items = <TourItemsCompanion>[];
      for (var i = 0; i < poisData.length; i++) {
        final poi = poisData[i];
        final poiId = poi['id'];
        
        items.add(TourItemsCompanion(
          id: Value(const Uuid().v4()),
          tourId: Value(tourData['id']),
          poiId: Value(poiId),
          orderIndex: Value(poi['order_index'] ?? i),
        ));

        // Also upsert POI
        await _db.poiDao.upsertPoi(
          PoisCompanion(
            id: Value(poiId),
            citySlug: Value(tourData['city_slug']),
            titleRu: Value(poi['title_ru']),
            descriptionRu: Value(poi['description_ru']),
            lat: Value(poi['lat']),
            lon: Value(poi['lon']),
          ),
          [], 
          [], 
        );
      }

      await _db.tourDao.upsertTourWithItems(tourComp, items);
  }
}

@riverpod
Future<ItineraryRepository> itineraryRepository(ItineraryRepositoryRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final dio = ref.watch(dioProvider);
  final db = ref.watch(appDatabaseProvider);
  return ItineraryRepository(prefs, dio, db);
}

@riverpod
class ItineraryIds extends _$ItineraryIds {
  @override
  Future<List<String>> build() async {
    final repo = await ref.watch(itineraryRepositoryProvider.future);
    return repo.getItineraryIds();
  }

  Future<void> add(String id) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.addToItinerary(id);
    state = AsyncData(repo.getItineraryIds());
  }

  Future<void> remove(String id) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.removeFromItinerary(id);
    state = AsyncData(repo.getItineraryIds());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.reorder(oldIndex, newIndex);
    state = AsyncData(repo.getItineraryIds());
  }
  
  Future<void> clear() async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.clear();
    state = const AsyncData([]);
  }
}
