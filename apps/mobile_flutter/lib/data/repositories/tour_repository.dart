import 'package:api_client/api.dart' as api;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/api/device_id_provider.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
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
  final Dio _dio;

  OfflineTourRepository(this._api, this._db, this._deviceId, String apiBaseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  @override
  Stream<List<domain.Tour>> watchTours(String citySlug) {
    // #region agent log
    print('[DEBUG f46abe] watchTours: starting watch for citySlug=$citySlug');
    // #endregion
    syncTours(citySlug).ignore();

    return _db.tourDao.watchToursByCity(citySlug).map((rows) {
      // #region agent log
      print('[DEBUG f46abe] watchTours: DB returned ${rows.length} tours');
      for (final r in rows) {
        print(
            '[DEBUG f46abe] watchTours DB ROW: id=${r.id}, title=${r.titleRu}, coverImage=${r.coverImage}');
      }
      // #endregion
      return rows
          .map((r) => domain.Tour(
                id: r.id,
                citySlug: r.citySlug,
                titleRu: r.titleRu,
                descriptionRu: r.descriptionRu,
                coverImage: r.coverImage,
                durationMinutes: r.durationMinutes,
                transportType: r.transportType,
                distanceKm: r.distanceKm,
                tourType: r.tourType,
              ))
          .toList();
    });
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
        items: details.items
            .map((i) => domain.TourItemEntity(
                  id: i.item.id,
                  tourId: i.item.tourId,
                  poiId: i.item.poiId,
                  orderIndex: i.item.orderIndex,
                  overrideLat: i.item.overrideLat,
                  overrideLon: i.item.overrideLon,
                  transitionTextRu: i.item.transitionTextRu,
                  transitionAudioUrl: i.item.transitionAudioUrl,
                  poi: i.poi != null
                      ? domain.Poi(
                          id: i.poi!.id,
                          citySlug: i.poi!.citySlug,
                          titleRu: i.poi!.titleRu,
                          descriptionRu: i.poi!.descriptionRu,
                          lat: i.poi!.lat,
                          lon: i.poi!.lon,
                          previewAudioUrl: i.poi!.previewAudioUrl,
                          hasAccess: i.poi!.hasAccess,
                          narrations: i.narrations
                              .map((n) => domain.Narration(
                                    id: n.id,
                                    url: n.url,
                                    locale: n.locale,
                                    durationSeconds: n.durationSeconds,
                                    transcript: n.transcript,
                                    localPath: n.localPath,
                                    kidsUrl: n.kidsUrl,
                                  ))
                              .toList(),
                          media: i.media
                              .map((m) => domain.Media(
                                    id: m.id,
                                    url: m.url,
                                    mediaType: m.mediaType,
                                  ))
                              .toList(),
                          sources: [],
                        )
                      : null,
                ))
            .toList(),
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
      print(
          '[DEBUG f46abe] syncTours: response status=${response.statusCode}, body=${response.body?.substring(0, (response.body?.length ?? 0) > 500 ? 500 : response.body?.length ?? 0)}');
      // #endregion
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final tours = await _api.apiClient
          .deserializeAsync(response.body, 'List<TourSnippet>') as List;
      // #region agent log
      print('[DEBUG f46abe] syncTours: deserialized ${tours.length} tours');
      if (tours.isNotEmpty) {
        final first = tours.first as api.TourSnippet;
        print(
            '[DEBUG f46abe] syncTours: first tour coverImage=${first.coverImage}, descriptionRu=${first.descriptionRu}');
      }
      // #endregion

      // Получаем ID туров с сервера
      final serverTourIds =
          tours.cast<api.TourSnippet>().map((t) => t.id!).toSet();

      // Удаляем туры из локальной БД, которых нет на сервере
      await _db.tourDao.deleteToursNotIn(citySlug, serverTourIds.toList());
      // #region agent log
      print('[DEBUG f46abe] syncTours: deleted tours not in server list');
      // #endregion

      final companions = tours
          .cast<api.TourSnippet>()
          .map((t) => ToursCompanion(
                id: Value(t.id!),
                citySlug: Value(t.citySlug!),
                titleRu: Value(t.titleRu!),
                descriptionRu: Value(t.descriptionRu),
                coverImage: Value(t.coverImage),
                durationMinutes: Value(t.durationMinutes),
                distanceKm: Value(t.distanceKm?.toDouble()),
                tourType: Value(t.tourType ?? 'walking'),
              ))
          .toList();

      await _db.tourDao.upsertTours(companions);
      // #region agent log
      print(
          '[DEBUG f46abe] syncTours: upserted ${companions.length} tours to DB');
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
    // #region agent log
    print(
        '[DEBUG f46abe] syncTourDetail: started for tourId=$id, citySlug=$citySlug');
    // #endregion
    try {
      final deviceId = await _deviceId;
      // #region agent log
      print(
          '[DEBUG f46abe] syncTourDetail: deviceId=$deviceId, calling /public/tours/$id/manifest');
      // #endregion

      // Вызываем GET /public/tours/{tour_id}/manifest
      final response = await _dio.get(
        '/public/tours/$id/manifest',
        queryParameters: {
          'city': citySlug,
          'device_anon_id': deviceId,
        },
      );

      // #region agent log
      print(
          '[DEBUG f46abe] syncTourDetail: response status=${response.statusCode}');
      // #endregion

      if (response.statusCode != 200) {
        // #region agent log
        print('[DEBUG f46abe] syncTourDetail: non-200 response, returning');
        // #endregion
        return;
      }

      final data = response.data as Map<String, dynamic>;
      // #region agent log
      print('[DEBUG f46abe] syncTourDetail: data keys=${data.keys.toList()}');
      // #endregion

      final tourData = data['tour'] as Map<String, dynamic>;
      final poisData = data['pois'] as List<dynamic>;

      // #region agent log
      print('[DEBUG f46abe] syncTourDetail: tourData=$tourData');
      print('[DEBUG f46abe] syncTourDetail: poisData count=${poisData.length}');
      // #endregion

      // Delete old tour items before inserting new ones to avoid duplicates
      await _db.tourDao.deleteTourItems(id);

      // Обновляем тур
      final tourComp = ToursCompanion(
        id: Value(tourData['id']),
        citySlug: Value(tourData['city_slug']),
        titleRu: Value(tourData['title_ru']),
        descriptionRu: Value(tourData['description_ru']),
        coverImage: Value(tourData['cover_image']),
        durationMinutes: Value(tourData['duration_minutes']),
        tourType: Value(tourData['tour_type'] ?? 'walking'),
        difficulty: Value(tourData['difficulty'] ?? 'easy'),
      );
      await _db.tourDao.upsertTours([tourComp]);

      // Обновляем POI и TourItems
      for (int i = 0; i < poisData.length; i++) {
        final poiData = poisData[i] as Map<String, dynamic>;
        final poiId = poiData['id'] as String;
        final orderIndex = poiData['order_index'] as int? ?? i;

        // #region agent log
        print(
            '[DEBUG f46abe] syncTourDetail: processing POI $i: id=$poiId, title=${poiData['title_ru']}');
        // #endregion

        // Upsert POI with all fields
        // Handle external_links - API returns List, but DB expects String (JSON)
        final externalLinksRaw = poiData['external_links'];
        String? externalLinksStr;
        if (externalLinksRaw is List) {
          externalLinksStr =
              externalLinksRaw.isNotEmpty ? externalLinksRaw.join(',') : null;
        } else if (externalLinksRaw is String) {
          externalLinksStr = externalLinksRaw;
        }

        final poiComp = PoisCompanion(
          id: Value(poiId),
          citySlug: Value(citySlug),
          titleRu: Value(poiData['title_ru'] ?? ''),
          descriptionRu: Value(poiData['description_ru']),
          lat: Value((poiData['lat'] as num?)?.toDouble() ?? 0.0),
          lon: Value((poiData['lon'] as num?)?.toDouble() ?? 0.0),
          category: Value(poiData['category']),
          openingHours: Value(poiData['opening_hours']),
          externalLinks: Value(externalLinksStr),
          wikidataId: Value(poiData['wikidata_id']),
          osmId: Value(poiData['osm_id']),
          previewAudioUrl: Value(poiData['preview_audio_url']),
        );
        await _db.poiDao.upsertPoiBasic(poiComp);

        // Upsert Narrations
        final narrationsData = poiData['narrations'] as List<dynamic>? ?? [];
        for (final n in narrationsData) {
          final narrComp = NarrationsCompanion(
            id: Value(n['id'] as String),
            poiId: Value(poiId),
            url: Value(n['url'] as String? ?? ''),
            locale: Value(n['locale'] as String? ?? 'ru'),
            durationSeconds: Value((n['duration_seconds'] as num?)?.toDouble()),
            transcript: Value(n['transcript'] as String?),
          );
          await _db.poiDao.upsertNarration(narrComp);
        }

        // Upsert Media
        final mediaData = poiData['media'] as List<dynamic>? ?? [];
        for (final m in mediaData) {
          final mediaComp = MediaCompanion(
            id: Value(m['id'] as String),
            poiId: Value(poiId),
            url: Value(m['url'] as String? ?? ''),
            mediaType: Value(m['type'] as String? ?? 'image'),
          );
          await _db.poiDao.upsertMedia(mediaComp);
        }

        // Upsert TourItem with override coordinates
        final itemId = const Uuid().v4();
        final overrideLat = (poiData['override_lat'] as num?)?.toDouble();
        final overrideLon = (poiData['override_lon'] as num?)?.toDouble();
        final transitionTextRu = poiData['transition_text_ru'] as String?;
        final transitionAudioUrl = poiData['transition_audio_url'] as String?;
        final itemComp = TourItemsCompanion(
          id: Value(itemId),
          tourId: Value(id),
          poiId: Value(poiId),
          orderIndex: Value(orderIndex),
          overrideLat: Value(overrideLat),
          overrideLon: Value(overrideLon),
          transitionTextRu: Value(transitionTextRu),
          transitionAudioUrl: Value(transitionAudioUrl),
        );
        await _db.tourDao.upsertTourItem(itemComp);
      }

      // #region agent log
      print(
          '[DEBUG f46abe] syncTourDetail: SUCCESS, ${poisData.length} POIs synced');
      // #endregion
    } catch (e, stack) {
      // #region agent log
      print('[DEBUG f46abe] syncTourDetail ERROR: $e');
      print('[DEBUG f46abe] syncTourDetail STACK: $stack');
      // #endregion
      final appError = ApiErrorMapper.map(e);
      print('Sync Tour Detail Error: ${appError.message}');
    }
  }
}

@riverpod
TourRepository tourRepository(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return OfflineTourRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(deviceIdProvider.future),
    config.apiBaseUrl,
  );
}
