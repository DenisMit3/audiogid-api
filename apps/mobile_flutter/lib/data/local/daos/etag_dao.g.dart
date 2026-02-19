// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etag_dao.dart';

// ignore_for_file: type=lint
mixin _$EtagDaoMixin on DatabaseAccessor<AppDatabase> {
  $EtagsTable get etags => attachedDatabase.etags;
  EtagDaoManager get managers => EtagDaoManager(this);
}

class EtagDaoManager {
  final _$EtagDaoMixin _db;
  EtagDaoManager(this._db);
  $$EtagsTableTableManager get etags =>
      $$EtagsTableTableManager(_db.attachedDatabase, _db.etags);
}
