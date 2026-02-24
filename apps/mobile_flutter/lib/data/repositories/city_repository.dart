import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/city.dart' as domain;
import 'package:mobile_flutter/domain/repositories/city_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'city_repository.g.dart';

class OfflineCityRepository implements CityRepository {
  final api.PublicApi _api;
  final AppDatabase _db;

  OfflineCityRepository(this._api, this._db);

  @override
  Stream<List<domain.City>> watchCities() {
    syncCities().ignore();

    return _db.cityDao.watchAllCities().map((rows) => rows
        .map((r) => domain.City(
              id: r.id,
              slug: r.slug,
              nameRu: r.nameRu,
              isActive: r.isActive,
              updatedAt: r.updatedAt,
            ))
        .toList());
  }

  @override
  Future<void> syncCities() async {
    // #region agent log
    print('[DEBUG f46abe] syncCities: started');
    // #endregion
    try {
      // #region agent log
      print('[DEBUG f46abe] syncCities: calling API');
      // #endregion
      final response = await _api.publicCitiesGetWithHttpInfo();
      // #region agent log
      print(
          '[DEBUG f46abe] syncCities: response status=${response.statusCode}, body length=${response.body?.length}');
      // #endregion
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final cities = await _api.apiClient
          .deserializeAsync(response.body, 'List<City>') as List;
      // #region agent log
      print('[DEBUG f46abe] syncCities: deserialized ${cities.length} cities');
      // #endregion
      final companions = cities
          .cast<api.City>()
          .map((c) => CitiesCompanion(
                id: Value(c.id!),
                slug: Value(c.slug!),
                nameRu: Value(c.nameRu!),
                isActive: Value(c.isActive!),
                updatedAt: Value(c.updatedAt),
              ))
          .toList();

      await _db.cityDao.upsertCities(companions);
      // #region agent log
      print(
          '[DEBUG f46abe] syncCities: upserted ${companions.length} cities to DB');
      // #endregion
    } catch (e) {
      // #region agent log
      print('[DEBUG f46abe] syncCities ERROR: $e');
      // #endregion
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync Cities Error: ${appError.message}');
    }
  }
}

@riverpod
CityRepository cityRepository(Ref ref) {
  return OfflineCityRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
  );
}
