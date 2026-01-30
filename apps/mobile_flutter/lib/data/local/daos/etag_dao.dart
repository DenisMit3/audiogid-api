import 'package:drift/drift.dart';
import '../app_database.dart';

part 'etag_dao.g.dart';

@DriftAccessor(tables: [Etags])
class EtagDao extends DatabaseAccessor<AppDatabase> with _$EtagDaoMixin {
  EtagDao(AppDatabase db) : super(db);

  Future<String?> getEtag(String url) async {
    final result = await (select(etags)..where((t) => t.url.equals(url))).getSingleOrNull();
    return result?.etag;
  }

  Future<void> updateEtag(String url, String etag) async {
    await into(etags).insertOnConflictUpdate(EtagsCompanion(
      url: Value(url),
      etag: Value(etag),
    ));
  }
}
