import 'package:drift/drift.dart';
import '../app_database.dart';

part 'entitlement_dao.g.dart';

@DriftAccessor(tables: [EntitlementGrants])
class EntitlementDao extends DatabaseAccessor<AppDatabase> with _$EntitlementDaoMixin {
  EntitlementDao(AppDatabase db) : super(db);

  Stream<List<EntitlementGrant>> watchAllGrants() => select(entitlementGrants).watch();
  
  Future<void> replaceAllGrants(List<EntitlementGrantsCompanion> entries) async {
    await transaction(() async {
      await delete(entitlementGrants).go();
      await batch((batch) {
        batch.insertAll(entitlementGrants, entries);
      });
    });
  }
}
