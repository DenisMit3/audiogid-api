// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_dao.dart';

// ignore_for_file: type=lint
mixin _$PoiDaoMixin on DatabaseAccessor<AppDatabase> {
  $PoisTable get pois => attachedDatabase.pois;
  $NarrationsTable get narrations => attachedDatabase.narrations;
  $MediaTable get media => attachedDatabase.media;
  $PoiSourcesTable get poiSources => attachedDatabase.poiSources;
  PoiDaoManager get managers => PoiDaoManager(this);
}

class PoiDaoManager {
  final _$PoiDaoMixin _db;
  PoiDaoManager(this._db);
  $$PoisTableTableManager get pois =>
      $$PoisTableTableManager(_db.attachedDatabase, _db.pois);
  $$NarrationsTableTableManager get narrations =>
      $$NarrationsTableTableManager(_db.attachedDatabase, _db.narrations);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db.attachedDatabase, _db.media);
  $$PoiSourcesTableTableManager get poiSources =>
      $$PoiSourcesTableTableManager(_db.attachedDatabase, _db.poiSources);
}
