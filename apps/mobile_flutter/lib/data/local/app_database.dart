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
  TextColumn get tourType => text().withDefault(const Constant('walking'))();
  TextColumn get difficulty => text().withDefault(const Constant('easy'))();

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
  TextColumn get wikidataId => text().nullable()();
  TextColumn get osmId => text().nullable()();
  RealColumn get confidenceScore => real().withDefault(const Constant(0.0))();
  TextColumn get openingHours => text().nullable()();
  TextColumn get externalLinks => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {citySlug, osmId}, // Composite unique
    {citySlug, category}, // Index hint
  ];
}

class Narrations extends Table {
  TextColumn get id => text()();
  TextColumn get poiId => text().references(Pois, #id, onDelete: OperationAction.cascade)();
  TextColumn get url => text()();
  TextColumn get locale => text()();
  RealColumn get durationSeconds => real().nullable()();
  TextColumn get transcript => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get voiceId => text().nullable()();
  IntColumn get filesizeBytes => integer().nullable()();

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

class AnalyticsPendingEvents extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
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
    AnalyticsPendingEvents,
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
  int get schemaVersion => 12;

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
           // ... (existing migrations) ...
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
          if (from < 9) {
            await m.addColumn(pois, pois.wikidataId);
            await m.addColumn(pois, pois.osmId);
            await m.addColumn(pois, pois.confidenceScore);
            await m.addColumn(pois, pois.openingHours);
            await m.addColumn(pois, pois.externalLinks);
            await m.addColumn(tours, tours.tourType);
            await m.addColumn(tours, tours.difficulty);
            await m.addColumn(narrations, narrations.voiceId);
            await m.addColumn(narrations, narrations.filesizeBytes);
          }
           if (from < 10) {
            await m.createTable(analyticsPendingEvents);
          }
          if (from < 11) {
            await m.createIndex(Index('idx_pois_city_category', 'CREATE INDEX idx_pois_city_category ON pois(city_slug, category)'));
          }
           if (from < 12) {
             await m.createIndex(Index('idx_tour_items_tour_order', 'CREATE INDEX idx_tour_items_tour_order ON tour_items(tour_id, order_index)'));
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
