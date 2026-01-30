import 'package:drift/drift.dart';
import '../app_database.dart';

part 'poi_dao.g.dart';

@DriftAccessor(tables: [Pois, Narrations, Media, PoiSources])
class PoiDao extends DatabaseAccessor<AppDatabase> with _$PoiDaoMixin {
  PoiDao(AppDatabase db) : super(db);

  Stream<PoiWithDetails?> watchPoi(String id) {
    final poiQuery = select(pois).join([
      leftOuterJoin(narrations, narrations.poiId.equalsExp(pois.id)),
      leftOuterJoin(media, media.poiId.equalsExp(pois.id)),
      leftOuterJoin(poiSources, poiSources.poiId.equalsExp(pois.id)),
    ])
      ..where(pois.id.equals(id));

    return poiQuery.watch().map((rows) {
      if (rows.isEmpty) return null;
      
      final poi = rows.first.readTable(pois);
      final allNarrations = rows
          .map((row) => row.readTableOrNull(narrations))
          .whereType<Narration>()
          .toSet()
          .toList();
      final allMedia = rows
          .map((row) => row.readTableOrNull(media))
          .whereType<Media>()
          .toSet()
          .toList();
      final allSources = rows
          .map((row) => row.readTableOrNull(poiSources))
          .whereType<PoiSource>()
          .toSet()
          .toList();

      return PoiWithDetails(poi, allNarrations, allMedia, allSources);
    });
  }

  Future<void> upsertPoi(
    PoisCompanion poi,
    List<NarrationsCompanion> nars,
    List<MediaCompanion> med,
    List<PoiSourcesCompanion> src,
  ) async {
    await transaction(() async {
      await into(pois).insertOnConflictUpdate(poi);

      // Preserve local paths from existing narrations
      final existingNarrations = await (select(narrations)..where((t) => t.poiId.equals(poi.id.value))).get();
      final localPaths = {for (final n in existingNarrations) n.id: n.localPath};

      await (delete(narrations)..where((t) => t.poiId.equals(poi.id.value))).go();
      await (delete(media)..where((t) => t.poiId.equals(poi.id.value))).go();
      await (delete(poiSources)..where((t) => t.poiId.equals(poi.id.value))).go();
      
      for (var n in nars) {
        var nToInsert = n;
        // Restore localPath if it existed
        final oldPath = localPaths[n.id.value];
        if (oldPath != null) {
          nToInsert = n.copyWith(localPath: Value(oldPath));
        }
        await into(narrations).insert(nToInsert);
      }
      for (var m in med) {
        await into(media).insert(m);
      }
      for (var s in src) {
        await into(poiSources).insert(s);
      }
    });
  }

  Future<void> toggleFavorite(String id) async {
    final poi = await (select(pois)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (poi != null) {
      await (update(pois)..where((t) => t.id.equals(id))).write(
        PoisCompanion(isFavorite: Value(!poi.isFavorite))
      );
    }
  }

  Stream<List<Poi>> watchFavorites() {
    return (select(pois)..where((t) => t.isFavorite.equals(true))).watch();
  }
}

class PoiWithDetails {
  final Poi poi;
  final List<Narration> narrations;
  final List<Media> media;
  final List<PoiSource> sources;

  PoiWithDetails(this.poi, this.narrations, this.media, this.sources);
}
