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
      descriptionRu: r.descriptionRu,
      coverImage: r.coverImage,
      durationMinutes: r.durationMinutes,
      transportType: r.transportType,
      distanceKm: r.distanceKm,
      tourType: r.tourType,
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
        descriptionRu: details.tour.descriptionRu,
        coverImage: details.tour.coverImage,
        durationMinutes: details.tour.durationMinutes,
        transportType: details.tour.transportType,
        distanceKm: details.tour.distanceKm,
        tourType: details.tour.tourType,
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
            sources: [], // Not loaded here for simplicity
          ) : null,
        )).toList(),
      );
    });
  }

  @override
  Future<void> syncTours(String citySlug) async {
    // #region agent log
    print('[DEBUG f46abe] syncTours: started for citySlug=$citySlug');
    // #endregion
    try {
      final response = await _api.publicCatalogGetWithHttpInfo(citySlug);
      // #region agent log
      print('[DEBUG f46abe] syncTours: response status=${response.statusCode}, body=${response.body?.substring(0, (response.body?.length ?? 0) > 500 ? 500 : response.body?.length ?? 0)}');
      // #endregion
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final tours = await _api.apiClient.deserializeAsync(response.body, 'List<TourSnippet>') as List;
      // #region agent log
      print('[DEBUG f46abe] syncTours: deserialized ${tours.length} tours');
      if (tours.isNotEmpty) {
        final first = tours.first as api.TourSnippet;
        print('[DEBUG f46abe] syncTours: first tour coverImage=${first.coverImage}, descriptionRu=${first.descriptionRu}');
      }
      // #endregion
      final companions = tours.cast<api.TourSnippet>().map((t) => ToursCompanion(
        id: Value(t.id!),
        citySlug: Value(t.citySlug!),
        titleRu: Value(t.titleRu!),
        descriptionRu: Value(t.descriptionRu),
        coverImage: Value(t.coverImage),
        durationMinutes: Value(t.durationMinutes),
        distanceKm: Value(t.distanceKm),
        tourType: Value(t.tourType ?? 'walking'),
      )).toList();

      await _db.tourDao.upsertTours(companions);
      // #region agent log
      print('[DEBUG f46abe] syncTours: upserted ${companions.length} tours to DB');
      // #endregion
    } catch (e) {
      // #region agent log
      print('[DEBUG f46abe] syncTours ERROR: $e');
      // #endregion
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync Tours Error: ${appError.message}');
    }
  }

  @override
  Future<void> syncTourDetail(String id, String citySlug) async {
    // TODO: API method publicToursTourIdManifestGetWithHttpInfo not available
    // Implement when API client is regenerated
    print('Sync Tour Detail for $id: API method not available');
  }
}

@riverpod
TourRepository tourRepository(Ref ref) {
  return OfflineTourRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(deviceIdProvider.future),
  );
}
