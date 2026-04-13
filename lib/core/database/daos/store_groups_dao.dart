import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/store_groups_table.dart';
import '../tables/store_group_members_table.dart';

part 'store_groups_dao.g.dart';

@DriftAccessor(tables: [StoreGroupsTable, StoreGroupMembersTable])
class StoreGroupsDao extends DatabaseAccessor<AppDatabase>
    with _$StoreGroupsDaoMixin {
  StoreGroupsDao(super.db);

  Stream<List<StoreGroupsTableData>> watchAll() =>
      select(storeGroupsTable).watch();

  /// Groups that contain a given store.
  Stream<List<StoreGroupsTableData>> watchGroupsForStore(String storeId) {
    final memberIds = selectOnly(storeGroupMembersTable)
      ..addColumns([storeGroupMembersTable.groupId])
      ..where(storeGroupMembersTable.storeId.equals(storeId));
    return (select(storeGroupsTable)
          ..where((t) => t.id.isInQuery(memberIds)))
        .watch();
  }

  Future<void> upsertGroup(StoreGroupsTableCompanion row) =>
      into(storeGroupsTable).insertOnConflictUpdate(row);

  Future<void> deleteGroup(String id) =>
      (delete(storeGroupsTable)..where((t) => t.id.equals(id))).go();

  Future<void> addMember(StoreGroupMembersTableCompanion row) =>
      into(storeGroupMembersTable).insertOnConflictUpdate(row);

  Future<void> removeMember(String groupId, String storeId) =>
      (delete(storeGroupMembersTable)
            ..where((t) =>
                t.groupId.equals(groupId) & t.storeId.equals(storeId)))
          .go();
}
