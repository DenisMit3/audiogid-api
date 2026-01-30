import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/api/device_id_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as domain;
import 'package:mobile_flutter/domain/entities/tour.dart' as domain;
import 'package:mobile_flutter/domain/repositories/tour_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tour_repository.g.dart';

class OfflineTourRepository implements TourRepository {
  final api.PublicApi _api;
  final AppDatabase _db;
  final Future<String> _deviceId;

  OfflineTourRepository(this._api, this._db, this._deviceId);

  @override
  Stream<List<domain.Tour>> watchTours(String citySlug) {
    syncTours(citySlug).ignore();
    
    return _db.tourDao.watchToursByCity(citySlug).map((rows) => rows.map((r) => domain.Tour(
      id: r.id,
      citySlug: r.citySlug,
      titleRu: r.titleRu,
      durationMinutes: r.durationMinutes,
      transportType: r.transportType,
      distanceKm: r.distanceKm,
    )).toList());
  }

  @override
  Stream<domain.Tour?> watchTour(String id) {
    return _db.tourDao.watchTourWithItems(id).map((details) {
      if (details == null) return null;
      
      return domain.Tour(
        id: details.tour.id,
        citySlug: details.tour.citySlug,
        titleRu: details.tour.titleRu,
        durationMinutes: details.tour.durationMinutes,
        transportType: details.tour.transportType,
        distanceKm: details.tour.distanceKm,
        items: details.items.map((i) => domain.TourItemEntity(
          id: i.item.id,
          tourId: i.item.tourId,
          poiId: i.item.poiId,
          orderIndex: i.item.orderIndex,
          poi: i.poi != null ? domain.Poi(
            id: i.poi!.id,
            citySlug: i.poi!.citySlug,
            titleRu: i.poi!.titleRu,
            descriptionRu: i.poi!.descriptionRu,
            lat: i.poi!.lat,
            lon: i.poi!.lon,
            previewAudioUrl: i.poi!.previewAudioUrl,
            hasAccess: i.poi!.hasAccess,
            narrations: [], // Not loaded here for simplicity
            media: [], // Not loaded here for simplicity
          ) : null,
        )).toList(),
      );
    });
  }

  @override
  Future<void> syncTours(String citySlug) async {
    try {
      final response = await _api.publicCatalogGetWithHttpInfo(citySlug);
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final tours = await _api.apiClient.deserializeAsync(response.body, 'List<TourSnippet>') as List;
      final companions = tours.cast<api.TourSnippet>().map((t) => ToursCompanion(
        id: Value(t.id!),
        citySlug: Value(t.citySlug!),
        titleRu: Value(t.titleRu!),
        durationMinutes: Value(t.durationMinutes),
        // Snippet might not have these yet, but we'll try to use them if they are added to the model
        // transportType: Value(t.transportType), 
        // distanceKm: Value(t.distanceKm),
      )).toList();

      await _db.tourDao.upsertTours(companions);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync Tours Error: ${appError.message}');
    }
  }

  @override
  Future<void> syncTourDetail(String id, String citySlug) async {
    try {
      final deviceId = await _deviceId;
      final response = await _api.publicToursTourIdManifestGetWithHttpInfo(id, citySlug, deviceId);
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      // The manifest response is not exactly a standard model in the generator?
      // Let's assume it maps to something we can use.
      final body = await _api.apiClient.deserializeAsync(response.body, 'Map<String, dynamic>') as Map<String, dynamic>;
      
      final tourData = body['tour'] as Map<String, dynamic>;
      final poisData = body['pois'] as List;

      final tourComp = ToursCompanion(
        id: Value(tourData['id']),
        citySlug: Value(tourData['city_slug']),
        titleRu: Value(tourData['title_ru']),
        durationMinutes: Value(tourData['duration_minutes']),
        transportType: Value(tourData['transport_type']),
        distanceKm: Value((tourData['distance_km'] as num?)?.toDouble()),
      );

      final items = <TourItemsCompanion>[];
      for (var i = 0; i < poisData.length; i++) {
        final poi = poisData[i];
        final poiId = poi['id'];
        
        items.add(TourItemsCompanion(
          id: Value(const Uuid().v4()),
          tourId: Value(id),
          poiId: Value(poiId),
          orderIndex: Value(poi['order_index'] ?? i),
        ));

        // Also upsert POI basic data
        await _db.poiDao.upsertPoi(
          PoisCompanion(
            id: Value(poiId),
            citySlug: Value(citySlug),
            titleRu: Value(poi['title_ru']),
            descriptionRu: Value(poi['description_ru']),
            lat: Value(poi['lat']),
            lon: Value(poi['lon']),
          ),
          [], // No narrations yet
          [], // No media yet
        );
      }

      await _db.tourDao.upsertTourWithItems(tourComp, items);
    } catch (e) {
      // ignore: avoid_print
      print('Sync Tour Detail Error: $e');
    }
  }
}

@riverpod
TourRepository tourRepository(TourRepositoryRef ref) {
  return OfflineTourRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(deviceIdProvider.future),
  );
}
