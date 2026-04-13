import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/store_memberships_table.dart';

part 'store_memberships_dao.g.dart';

@DriftAccessor(tables: [StoreMembershipsTable])
class StoreMembershipsDao extends DatabaseAccessor<AppDatabase>
    with _$StoreMembershipsDaoMixin {
  StoreMembershipsDao(super.db);

  /// All active memberships for a store (for members screen).
  Stream<List<StoreMembershipsTableData>> watchByStore(String storeId) =>
      (select(storeMembershipsTable)
            ..where((t) => t.storeId.equals(storeId))
            ..orderBy([(t) => OrderingTerm.asc(t.joinedAt)]))
          .watch();

  /// All memberships (any status) for a given user.
  Stream<List<StoreMembershipsTableData>> watchByUser(String userUid) =>
      (select(storeMembershipsTable)
            ..where((t) => t.userUid.equals(userUid)))
          .watch();

  /// Active membership for a specific user in a specific store.
  Future<StoreMembershipsTableData?> findActive(String storeId, String userUid) =>
      (select(storeMembershipsTable)
            ..where((t) =>
                t.storeId.equals(storeId) &
                t.userUid.equals(userUid) &
                t.status.equals('active')))
          .getSingleOrNull();

  /// Pending requests for a store (for approval queue).
  Stream<List<StoreMembershipsTableData>> watchPending(String storeId) =>
      (select(storeMembershipsTable)
            ..where((t) =>
                t.storeId.equals(storeId) & t.status.equals('pending')))
          .watch();

  Future<void> upsert(StoreMembershipsTableCompanion row) =>
      into(storeMembershipsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(storeMembershipsTable)..where((t) => t.id.equals(id))).go();
}
