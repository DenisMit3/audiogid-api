import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'daos/city_dao.dart';
import 'daos/tour_dao.dart';
import 'daos/poi_dao.dart';
import 'daos/entitlement_dao.dart';
import 'daos/etag_dao.dart';

part 'app_database.g.dart';

class Cities extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text()();
  TextColumn get nameRu => text()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tours extends Table {
  TextColumn get id => text()();
  TextColumn get citySlug => text()();
  TextColumn get titleRu => text()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get transportType => text().nullable()();
  RealColumn get distanceKm => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TourItems extends Table {
  TextColumn get id => text()();
  TextColumn get tourId => text().references(Tours, #id, onDelete: OperationAction.cascade)();
  TextColumn get poiId => text().references(Pois, #id, onDelete: OperationAction.cascade)();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Pois extends Table {
  TextColumn get id => text()();
  TextColumn get citySlug => text()();
  TextColumn get titleRu => text()();
  TextColumn get descriptionRu => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get previewAudioUrl => text().nullable()();
  BoolColumn get hasAccess => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Narrations extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id, onDelete: OperationAction.cascade)();
  TextColumn get url => text()();
  TextColumn get locale => text()();
  RealColumn get durationSeconds => real().nullable()();
  TextColumn get transcript => text().nullable()();
  TextColumn get localPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Media extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id, onDelete: OperationAction.cascade)();
  TextColumn get url => text()();
  TextColumn get mediaType => text()();
  TextColumn get author => text().nullable()();
  TextColumn get sourcePageUrl => text().nullable()();
  TextColumn get licenseType => text().nullable()();
  TextColumn get localPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PoiSources extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id, onDelete: OperationAction.cascade)();
  TextColumn get name => text()();
  TextColumn get url => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class EntitlementGrants extends Table {
  TextColumn get id => text()();
  TextColumn get entitlementSlug => text()();
  TextColumn get scope => text()();
  TextColumn get ref => text().nullable()();
  DateTimeColumn get grantedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class Etags extends Table {
  TextColumn get url => text()();
  TextColumn get etag => text()();

  @override
  Set<Column> get primaryKey => {url};
}

class QrMappingsCache extends Table {
  TextColumn get code => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get redirectUrl => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {code};
}

@DriftDatabase(
  tables: [
    Cities,
    Tours,
    TourItems,
    Pois,
    Narrations,
    Media,
    PoiSources,
    EntitlementGrants,
    Etags,
    QrMappingsCache,
  ],
  daos: [
    CityDao,
    TourDao,
    PoiDao,
    EntitlementDao,
    EtagDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            for (final table in allTables) {
              await m.createTable(table);
            }
          }
          if (from < 4) {
             await m.addColumn(tours, tours.transportType);
             await m.addColumn(tours, tours.distanceKm);
          }
          if (from < 5) {
            await m.addColumn(pois, pois.isFavorite);
            await m.addColumn(pois, pois.category);
            await m.addColumn(media, media.licenseType);
            await m.addColumn(narrations, narrations.transcript);
            await m.createTable(poiSources);
          }
          if (from < 6) {
            await m.addColumn(narrations, narrations.localPath);
          }
          if (from < 7) {
            await m.addColumn(media, media.localPath);
          }
          if (from < 8) {
            await m.createTable(qrMappingsCache);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
