// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dao.dart';

// ignore_for_file: type=lint
mixin _$CityDaoMixin on DatabaseAccessor<AppDatabase> {
  $CitiesTable get cities => attachedDatabase.cities;
  CityDaoManager get managers => CityDaoManager(this);
}

class CityDaoManager {
  final _$CityDaoMixin _db;
  CityDaoManager(this._db);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db.attachedDatabase, _db.cities);
}
