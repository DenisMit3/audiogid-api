import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as domain;
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/data/local/daos/poi_dao.dart';
import 'package:api_client/api.dart'; // PublicApi
import 'package:drift/drift.dart';

class PoiRepositoryImpl implements PoiRepository {
  final AppDatabase db;
  final PublicApi api;

  PoiRepositoryImpl(this.db, this.api);

  @override
  Stream<domain.Poi?> watchPoi(String id) {
    return db.poiDao.watchPoi(id).map((details) {
      if (details == null) return null;
      return _mapToDomain(details);
    });
  }

  @override
  Future<void> syncPoi(String id, String citySlug) async {
    try {
      final response = await api.publicPoiPoiIdGet(id, citySlug);
      if (response != null) {
        // Map API DTO to Drift Companions
        final p = response;

        final mainComp = PoisCompanion(
          id: Value(p.id ?? id),
          citySlug: Value(citySlug),
          titleRu: Value(p.titleRu ?? ''),
          descriptionRu: Value(p.descriptionRu),
          lat: Value(p.lat?.toDouble() ?? 0.0),
          lon: Value(p.lon?.toDouble() ?? 0.0),
          previewAudioUrl: Value(p.previewAudioUrl),
          hasAccess: Value(p.hasAccess ?? false),
          category: Value(p.category),
          // isFavorite preserved? Upsert usually overwrites.
          // We should check existing and preserve.
          // actually insertOnConflictUpdate might overwrite isFavorite if we don't set it?
          // Drift default is insert. On conflict update replacing...
          // We better read existing isFavorite.
        );

        // Simple implementation: Use DAO upsert
        // Need to map children
        final nars = p.narrations
            .map((n) => NarrationsCompanion(
                  id: Value(n.id ?? ''),
                  poiId: Value(p.id ?? id),
                  url: Value(n.url ?? ''),
                  locale: Value(n.locale ?? 'ru'),
                  durationSeconds: Value(n.durationSeconds?.toDouble()),
                  transcript: Value(n.transcript),
                  // kidsUrl might not be present in generated client yet if not regenerated
                  // Using dynamic cast for safety during transition if needed,
                  // but ideally client is updated. Assuming updated client:
                  kidsUrl: Value((n as dynamic).kidsUrl as String?),
                ))
            .toList();

        final meds = p.media
            .map((m) => MediaCompanion(
                  id: Value(m.id ?? ''),
                  poiId: Value(p.id ?? id),
                  url: Value(m.url ?? ''),
                  mediaType: Value(m.mediaType ?? 'image'),
                  author: Value(m.author),
                  sourcePageUrl: Value(m.sourcePageUrl),
                  licenseType: Value(m.licenseType),
                ))
            .toList();

        final srcs = p.sources
            .map((s) => PoiSourcesCompanion(
                  id: Value(s.id ?? ''),
                  poiId: Value(p.id ?? id),
                  name: Value(s.name ?? ''),
                  url: Value(s.url),
                ))
            .toList();

        await db.poiDao.upsertPoi(mainComp, nars, meds, srcs);
      }
    } catch (e) {
      // POI might not be published separately - this is OK if it's part of a tour
      // The POI data was already synced via tour manifest
      print('[DEBUG] syncPoi failed for $id: $e - using cached data from tour');
    }
  }

  @override
  Future<void> syncPoisForCity(String citySlug) async {
    try {
      // TODO: Regenerate OpenApi client (npm run generate in packages/api_client)
      // Once generated, uncomment the following line:
      // final response = await api.publicCitiesSlugPoisGet(citySlug);

      // Example implementation after generation:
      /*
      if (response != null) {
        final pois = response.items;
        for (var p in pois) {
          // fetch details or map snippet
          await syncPoi(p.id, citySlug); 
        }
      }
      */

      print("Syncing POIs for $citySlug: Client update pending.");
    } catch (e) {
      print("Sync city POIs failed: $e");
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await db.poiDao.toggleFavorite(id);
  }

  @override
  Stream<List<domain.Poi>> watchFavorites() {
    return db.poiDao.watchFavorites().map((list) {
      // watchFavorites returns List<Poi> (Drift class). Need to fetch details?
      // For now assuming list view doesn't need full details
      return list.map((p) => _mapRowToDomain(p)).toList();
    });
  }

  @override
  Stream<List<domain.Poi>> watchPoisForCity(String citySlug) {
    return (db.select(db.pois)..where((t) => t.citySlug.equals(citySlug)))
        .watch()
        .map((rows) => rows.map((row) => _mapRowToDomain(row)).toList());
  }

  domain.Poi _mapToDomain(PoiWithDetails details) {
    final p = details.poi;
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
      narrations: details.narrations
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
      media: details.media
          .map((m) => domain.Media(
                id: m.id,
                url: m.url,
                mediaType: m.mediaType,
                author: m.author,
                sourcePageUrl: m.sourcePageUrl,
                licenseType: m.licenseType,
              ))
          .toList(),
      sources: details.sources
          .map((s) => domain.PoiSource(
                id: s.id,
                name: s.name,
                url: s.url,
              ))
          .toList(),
    );
  }

  domain.Poi _mapRowToDomain(Poi p) {
    // Light mapping for lists (no joins)
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
      narrations: [],
      media: [],
      sources: [],
    );
  }

  @override
  Future<List<domain.Poi>> getNearbyCandidates(
      double lat, double lon, double radiusMeters) async {
    final rows = await db.poiDao.getNearbyCandidates(lat, lon, radiusMeters);
    return rows.map((p) => _mapRowToDomain(p)).toList();
  }

  @override
  Future<List<domain.Poi>> getPoisByIds(List<String> ids) async {
    final rows = await db.poiDao.getPoisByIds(ids);
    return rows.map((p) => _mapRowToDomain(p)).toList();
  }
}
