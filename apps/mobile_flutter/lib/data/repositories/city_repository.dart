import 'package:api_client/api.dart' as api;
import 'package:drift/drift.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/error/api_error.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/domain/entities/city.dart';
import 'package:mobile_flutter/domain/repositories/city_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'city_repository.g.dart';

class OfflineCityRepository implements CityRepository {
  final api.PublicApi _api;
  final AppDatabase _db;

  OfflineCityRepository(this._api, this._db);

  @override
  Stream<List<City>> watchCities() {
    syncCities().ignore(); 
    
    return _db.cityDao.watchAllCities().map((rows) => rows.map((r) => City(
      id: r.id,
      slug: r.slug,
      nameRu: r.nameRu,
      isActive: r.isActive,
      updatedAt: r.updatedAt,
    )).toList());
  }

  @override
  Future<void> syncCities() async {
    try {
      final response = await _api.publicCitiesGetWithHttpInfo();
      if (response.statusCode == 304) return;
      if (response.statusCode >= 400) return;

      final cities = await _api.apiClient.deserializeAsync(response.body, 'List<City>') as List;
      final companions = cities.cast<api.City>().map((c) => CitiesCompanion(
        id: Value(c.id!),
        slug: Value(c.slug!),
        nameRu: Value(c.nameRu!),
        isActive: Value(c.isActive!),
        updatedAt: Value(c.updatedAt),
      )).toList();

      await _db.cityDao.upsertCities(companions);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      // ignore: avoid_print
      print('Sync Cities Error: ${appError.message}');
    }
  }
}

@riverpod
CityRepository cityRepository(CityRepositoryRef ref) {
  return OfflineCityRepository(
    ref.watch(publicApiProvider),
    ref.watch(appDatabaseProvider),
  );
}
