import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/planograms_table.dart';

part 'planograms_dao.g.dart';

@DriftAccessor(tables: [PlanogramsTable])
class PlanogramsDao extends DatabaseAccessor<AppDatabase>
    with _$PlanogramsDaoMixin {
  PlanogramsDao(super.db);

  Stream<List<PlanogramsTableData>> watchAll() =>
      select(planogramsTable).watch();

  Stream<List<PlanogramsTableData>> watchByStore(String storeId) =>
      (select(planogramsTable)
            ..where((t) => t.storeId.equals(storeId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Legacy alias — some older callers filtered by fixtureId.
  Stream<List<PlanogramsTableData>> watchByParentId(String fixtureId) =>
      (select(planogramsTable)..where((t) => t.fixtureId.equals(fixtureId)))
          .watch();

  Future<PlanogramsTableData?> findById(String id) =>
      (select(planogramsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsert(PlanogramsTableCompanion row) =>
      into(planogramsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(planogramsTable)..where((t) => t.id.equals(id))).go();
}
