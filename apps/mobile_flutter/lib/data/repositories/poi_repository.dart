import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as domain;
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'poi_repository.g.dart';

class OfflinePoiRepository implements PoiRepository {
  final api.PublicApi _api;
  final AppDatabase _db;

  OfflinePoiRepository(this._api, this._db);

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
    // TODO: API method publicPoiGetWithHttpInfo not available in current api_client
    // Implement when API client is regenerated
    print('Sync POIs for city $citySlug: API method not available');
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
  return OfflinePoiRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
  );
}
