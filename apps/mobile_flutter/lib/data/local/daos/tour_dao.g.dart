// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_dao.dart';

// ignore_for_file: type=lint
mixin _$TourDaoMixin on DatabaseAccessor<AppDatabase> {
  $ToursTable get tours => attachedDatabase.tours;
  $PoisTable get pois => attachedDatabase.pois;
  $TourItemsTable get tourItems => attachedDatabase.tourItems;
  $NarrationsTable get narrations => attachedDatabase.narrations;
  $MediaTable get media => attachedDatabase.media;
  TourDaoManager get managers => TourDaoManager(this);
}

class TourDaoManager {
  final _$TourDaoMixin _db;
  TourDaoManager(this._db);
  $$ToursTableTableManager get tours =>
      $$ToursTableTableManager(_db.attachedDatabase, _db.tours);
  $$PoisTableTableManager get pois =>
      $$PoisTableTableManager(_db.attachedDatabase, _db.pois);
  $$TourItemsTableTableManager get tourItems =>
      $$TourItemsTableTableManager(_db.attachedDatabase, _db.tourItems);
  $$NarrationsTableTableManager get narrations =>
      $$NarrationsTableTableManager(_db.attachedDatabase, _db.narrations);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db.attachedDatabase, _db.media);
}
