import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/planograms_table.dart';

part 'planograms_dao.g.dart';

@DriftAccessor(tables: [PlanogramsTable])
class PlanogramsDao extends DatabaseAccessor<AppDatabase> with _$PlanogramsDaoMixin {
  PlanogramsDao(super.db);

  Stream<List<PlanogramsTableData>> watchAll() => select(planogramsTable).watch();

  Stream<List<PlanogramsTableData>> watchByParentId(String fixtureId) =>
      (select(planogramsTable)..where((t) => t.fixtureId.equals(fixtureId))).watch();

  Future<void> upsert(PlanogramsTableCompanion row) =>
      into(planogramsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(planogramsTable)..where((t) => t.id.equals(id))).go();
}
