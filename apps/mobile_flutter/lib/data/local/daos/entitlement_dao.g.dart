// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_dao.dart';

// ignore_for_file: type=lint
mixin _$EntitlementDaoMixin on DatabaseAccessor<AppDatabase> {
  $EntitlementGrantsTable get entitlementGrants =>
      attachedDatabase.entitlementGrants;
  EntitlementDaoManager get managers => EntitlementDaoManager(this);
}

class EntitlementDaoManager {
  final _$EntitlementDaoMixin _db;
  EntitlementDaoManager(this._db);
  $$EntitlementGrantsTableTableManager get entitlementGrants =>
      $$EntitlementGrantsTableTableManager(
          _db.attachedDatabase, _db.entitlementGrants);
}
