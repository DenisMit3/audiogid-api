import 'package:drift/drift.dart';
import '../app_database.dart';

part 'tour_dao.g.dart';

@DriftAccessor(tables: [Tours, TourItems, Pois])
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

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;

      final tour = rows.first.readTable(tours);
      final items = rows
          .map((row) {
            final item = row.readTableOrNull(tourItems);
            final poi = row.readTableOrNull(pois);
            if (item == null) return null;
            return TourItemWithPoi(item, poi);
          })
          .whereType<TourItemWithPoi>()
          .toList();

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
  TourItemWithPoi(this.item, this.poi);
}
