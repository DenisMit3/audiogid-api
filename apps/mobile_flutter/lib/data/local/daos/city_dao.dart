import 'package:drift/drift.dart';
import '../app_database.dart';

part 'city_dao.g.dart';

@DriftAccessor(tables: [Cities])
class CityDao extends DatabaseAccessor<AppDatabase> with _$CityDaoMixin {
  CityDao(AppDatabase db) : super(db);

  Stream<List<City>> watchAllCities() => select(cities).watch();
  Future<List<City>> getAllCities() => select(cities).get();
  Future<void> upsertCities(List<CitiesCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(cities, entries);
    });
  }
}
