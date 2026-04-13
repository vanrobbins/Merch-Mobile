import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/photo_docs_table.dart';

part 'photo_docs_dao.g.dart';

@DriftAccessor(tables: [PhotoDocsTable])
class PhotoDocsDao extends DatabaseAccessor<AppDatabase> with _$PhotoDocsDaoMixin {
  PhotoDocsDao(super.db);

  Stream<List<PhotoDocsTableData>> watchAll() => select(photoDocsTable).watch();

  Stream<List<PhotoDocsTableData>> watchByParentId(String fixtureId) =>
      (select(photoDocsTable)..where((t) => t.fixtureId.equals(fixtureId))).watch();

  Future<void> upsert(PhotoDocsTableCompanion row) =>
      into(photoDocsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(photoDocsTable)..where((t) => t.id.equals(id))).go();
}
