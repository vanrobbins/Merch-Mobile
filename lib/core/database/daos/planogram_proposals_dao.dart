import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/planogram_proposals_table.dart';

part 'planogram_proposals_dao.g.dart';

@DriftAccessor(tables: [PlanogramProposalsTable])
class PlanogramProposalsDao extends DatabaseAccessor<AppDatabase>
    with _$PlanogramProposalsDaoMixin {
  PlanogramProposalsDao(super.db);

  Stream<List<PlanogramProposalsTableData>> watchByStore(String storeId) =>
      (select(planogramProposalsTable)
            ..where((t) => t.storeId.equals(storeId))
            ..orderBy([(t) => OrderingTerm.desc(t.proposedAt)]))
          .watch();

  Stream<List<PlanogramProposalsTableData>> watchPendingByStore(
          String storeId) =>
      (select(planogramProposalsTable)
            ..where((t) =>
                t.storeId.equals(storeId) & t.status.equals('pending')))
          .watch();

  Stream<List<PlanogramProposalsTableData>> watchByUser(
          String storeId, String userUid) =>
      (select(planogramProposalsTable)
            ..where((t) =>
                t.storeId.equals(storeId) &
                t.proposedByUid.equals(userUid)))
          .watch();

  Future<void> upsert(PlanogramProposalsTableCompanion row) =>
      into(planogramProposalsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(planogramProposalsTable)..where((t) => t.id.equals(id))).go();
}
