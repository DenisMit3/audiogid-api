import 'package:api_client/api.dart' as api;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/config/app_config.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as domain;
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'poi_repository.g.dart';

class OfflinePoiRepository implements PoiRepository {
  final api.PublicApi _api;
  final AppDatabase _db;
  final Dio _dio;

  OfflinePoiRepository(this._api, this._db, String apiBaseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  @override
  Stream<domain.Poi?> watchPoi(String id) {
    return _db.poiDao.watchPoi(id).map((details) {
      if (details == null) return null;
      
      return domain.Poi(
        id: details.poi.id,
        citySlug: details.poi.citySlug,
        titleRu: details.poi.titleRu,
        descriptionRu: details.poi.descriptionRu,
        lat: details.poi.lat,
        lon: details.poi.lon,
        previewAudioUrl: details.poi.previewAudioUrl,
        hasAccess: details.poi.hasAccess,
        isFavorite: details.poi.isFavorite,
        category: details.poi.category,
        narrations: details.narrations.map((n) => domain.Narration(
          id: n.id,
          url: n.url,
          locale: n.locale,
          durationSeconds: n.durationSeconds,
          transcript: n.transcript,
        )).toList(),
        media: details.media.map((m) => domain.Media(
          id: m.id,
          url: m.url,
          mediaType: m.mediaType,
          author: m.author,
          sourcePageUrl: m.sourcePageUrl,
          licenseType: m.licenseType,
        )).toList(),
        sources: details.sources.map((s) => domain.PoiSource(
          id: s.id,
          name: s.name,
          url: s.url,
        )).toList(),
      );
    });
  }

  @override
  Future<void> syncPoi(String id, String citySlug) async {
    try {
      final response = await _api.publicPoiPoiIdGetWithHttpInfo(id, citySlug);
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final data = await _api.apiClient.deserializeAsync(response.body, 'PoiDetail') as api.PoiDetail;

      final poiComp = PoisCompanion(
        id: Value(data.id!),
        citySlug: Value(citySlug),
        titleRu: Value(data.titleRu!),
        descriptionRu: Value(data.descriptionRu),
        lat: Value(data.lat!.toDouble()),
        lon: Value(data.lon!.toDouble()),
        previewAudioUrl: Value(data.previewAudioUrl),
        hasAccess: Value(data.hasAccess!),
        category: Value(data.category),
      );

      final nars = data.narrations.map((n) => NarrationsCompanion(
        id: Value(n.id!),
        poiId: Value(data.id!),
        url: Value(n.url!),
        locale: Value(n.locale!),
        durationSeconds: Value(n.durationSeconds?.toDouble()),
        transcript: Value((n as dynamic).transcript as String?),
      )).toList();

      final meds = data.media.map((m) => MediaCompanion(
        id: Value(m.id!),
        poiId: Value(data.id!),
        url: Value(m.url!),
        mediaType: Value(m.mediaType!),
        author: Value(m.author),
        sourcePageUrl: Value(m.sourcePageUrl),
        licenseType: Value((m as dynamic).licenseType as String?),
      )).toList();

      final srcs = (data as dynamic).sources?.map((s) => PoiSourcesCompanion(
        id: Value(s.id!),
        poiId: Value(data.id!),
        name: Value(s.name!),
        url: Value(s.url),
      )).toList() ?? <PoiSourcesCompanion>[];

      await _db.poiDao.upsertPoi(poiComp, nars, meds, srcs);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync POI Error: ${appError.message}');
    }
  }

  @override
  Future<void> syncPoisForCity(String citySlug) async {
    try {
      // Вызываем GET /public/cities/{slug}/pois с пагинацией
      int page = 1;
      const perPage = 50;
      int totalFetched = 0;

      while (true) {
        final response = await _dio.get(
          '/public/cities/$citySlug/pois',
          queryParameters: {
            'page': page,
            'per_page': perPage,
          },
        );

        if (response.statusCode != 200) break;

        final data = response.data as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;
        final total = data['total'] as int? ?? 0;

        if (items.isEmpty) break;

        // Сохраняем POI в локальную БД
        for (final item in items) {
          final poiData = item as Map<String, dynamic>;
          final poiComp = PoisCompanion(
            id: Value(poiData['id'] as String),
            citySlug: Value(citySlug),
            titleRu: Value(poiData['title_ru'] as String? ?? ''),
            category: Value(poiData['category'] as String?),
            lat: Value((poiData['lat'] as num?)?.toDouble() ?? 0.0),
            lon: Value((poiData['lon'] as num?)?.toDouble() ?? 0.0),
          );
          await _db.poiDao.upsertPoiBasic(poiComp);
        }

        totalFetched += items.length;
        
        // Проверяем, есть ли еще страницы
        if (totalFetched >= total || items.length < perPage) break;
        page++;
      }

      print('Sync POIs for city $citySlug: success, $totalFetched POIs');
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      print('Sync POIs for city Error: ${appError.message}');
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _db.poiDao.toggleFavorite(id);
  }

  @override
  Stream<List<domain.Poi>> watchFavorites() {
    return _db.poiDao.watchFavorites().map((list) => list.map(_mapTablePoiToDomain).toList());
  }

  @override
  Stream<List<domain.Poi>> watchPoisForCity(String citySlug) {
    return (_db.select(_db.pois)..where((t) => t.citySlug.equals(citySlug))).watch().map(
      (list) => list.map(_mapTablePoiToDomain).toList()
    );
  }

  @override
  Future<List<domain.Poi>> getNearbyCandidates(double lat, double lon, double radiusMeters) async {
    final list = await _db.poiDao.getNearbyCandidates(lat, lon, radiusMeters);
    return list.map(_mapTablePoiToDomain).toList();
  }

  @override
  Future<List<domain.Poi>> getPoisByIds(List<String> ids) async {
    final list = await _db.poiDao.getPoisByIds(ids);
    return list.map(_mapTablePoiToDomain).toList();
  }

  domain.Poi _mapTablePoiToDomain(Poi p) {
    return domain.Poi(
      id: p.id,
      citySlug: p.citySlug,
      titleRu: p.titleRu,
      descriptionRu: p.descriptionRu,
      lat: p.lat,
      lon: p.lon,
      previewAudioUrl: p.previewAudioUrl,
      hasAccess: p.hasAccess,
      isFavorite: p.isFavorite,
      category: p.category,
      narrations: [], // Detail watchers will fill these
      media: [],
      sources: [],
    );
  }
}

@riverpod
PoiRepository poiRepository(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return OfflinePoiRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
    config.apiBaseUrl,
  );
}
