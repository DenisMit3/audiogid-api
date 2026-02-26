import 'package:drift/drift.dart';
import '../app_database.dart';

part 'tour_dao.g.dart';

@DriftAccessor(tables: [Tours, TourItems, Pois, Narrations, Media])
class TourDao extends DatabaseAccessor<AppDatabase> with _$TourDaoMixin {
  TourDao(AppDatabase db) : super(db);

  Stream<List<Tour>> watchToursByCity(String citySlug) {
    return (select(tours)..where((t) => t.citySlug.equals(citySlug))).watch();
  }

  Stream<TourWithItems?> watchTourWithItems(String tourId) {
    final query = select(tours).join([
      leftOuterJoin(tourItems, tourItems.tourId.equalsExp(tours.id)),
      leftOuterJoin(pois, pois.id.equalsExp(tourItems.poiId)),
    ])
      ..where(tours.id.equals(tourId));

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;

      final tour = rows.first.readTable(tours);
      final items = <TourItemWithPoi>[];

      for (final row in rows) {
        final item = row.readTableOrNull(tourItems);
        final poi = row.readTableOrNull(pois);
        if (item == null) continue;

        // Load narrations for this POI
        List<Narration> poiNarrations = [];
        List<MediaData> poiMedia = [];
        if (poi != null) {
          poiNarrations = await (select(narrations)
                ..where((n) => n.poiId.equals(poi.id)))
              .get();
          poiMedia =
              await (select(media)..where((m) => m.poiId.equals(poi.id))).get();
        }

        items.add(TourItemWithPoi(item, poi, poiNarrations, poiMedia));
      }

      items.sort((a, b) => a.item.orderIndex.compareTo(b.item.orderIndex));

      return TourWithItems(tour, items);
    });
  }

  Future<void> upsertTours(List<ToursCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(tours, entries);
    });
  }

  Future<void> upsertTourWithItems(
      ToursCompanion tour, List<TourItemsCompanion> items) async {
    await transaction(() async {
      await into(tours).insertOnConflictUpdate(tour);
      await (delete(tourItems)..where((t) => t.tourId.equals(tour.id.value)))
          .go();
      for (var item in items) {
        await into(tourItems).insert(item);
      }
    });
  }

  Future<void> deleteToursByCity(String citySlug) {
    return (delete(tours)..where((t) => t.citySlug.equals(citySlug))).go();
  }

  /// Удаляет туры города, которых нет в списке serverIds
  Future<void> deleteToursNotIn(String citySlug, List<String> serverIds) async {
    if (serverIds.isEmpty) {
      // Если сервер вернул пустой список - удаляем все туры города
      await deleteToursByCity(citySlug);
      return;
    }
    await (delete(tours)
          ..where((t) => t.citySlug.equals(citySlug) & t.id.isNotIn(serverIds)))
        .go();
  }

  /// Удаляет все TourItems для указанного тура
  Future<void> deleteTourItems(String tourId) {
    return (delete(tourItems)..where((t) => t.tourId.equals(tourId))).go();
  }

  /// Upsert одного TourItem (для инкрементального обновления)
  Future<void> upsertTourItem(TourItemsCompanion item) async {
    await into(tourItems).insertOnConflictUpdate(item);
  }
}

class TourWithItems {
  final Tour tour;
  final List<TourItemWithPoi> items;
  TourWithItems(this.tour, this.items);
}

class TourItemWithPoi {
  final TourItem item;
  final Poi? poi;
  final List<Narration> narrations;
  final List<MediaData> media;
  TourItemWithPoi(this.item, this.poi, this.narrations, this.media);
}
