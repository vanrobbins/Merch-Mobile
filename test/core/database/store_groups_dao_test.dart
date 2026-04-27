import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  group('StoreGroupsDao', () {
    test('upsertGroup persists group and watchAll emits it', () async {
      await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
        id: 'g1',
        name: 'Northeast Region',
        createdByUid: 'owner',
        createdAt: 1000,
      ));
      final groups = await db.storeGroupsDao.watchAll().first;
      expect(groups.length, 1);
      expect(groups.first.name, 'Northeast Region');
    });

    test('deleteGroup removes the group', () async {
      await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
        id: 'g2',
        name: 'Temp',
        createdByUid: 'owner',
        createdAt: 0,
      ));
      await db.storeGroupsDao.deleteGroup('g2');
      final groups = await db.storeGroupsDao.watchAll().first;
      expect(groups, isEmpty);
    });

    test('addMember + watchGroupsForStore returns groups containing the store',
        () async {
      await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
        id: 'g3',
        name: 'West',
        createdByUid: 'owner',
        createdAt: 0,
      ));
      await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
        id: 'g4',
        name: 'East',
        createdByUid: 'owner',
        createdAt: 0,
      ));
      // g3 contains storeA; g4 does not.
      await db.storeGroupsDao.addMember(StoreGroupMembersTableCompanion.insert(
        id: 'mem1',
        groupId: 'g3',
        storeId: 'storeA',
        addedAt: 0,
        addedByUid: 'owner',
      ));

      final groups =
          await db.storeGroupsDao.watchGroupsForStore('storeA').first;
      expect(groups.length, 1);
      expect(groups.first.id, 'g3');
    });

    test('removeMember detaches a store from a group', () async {
      await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
        id: 'g5',
        name: 'Group5',
        createdByUid: 'owner',
        createdAt: 0,
      ));
      await db.storeGroupsDao
          .addMember(StoreGroupMembersTableCompanion.insert(
        id: 'mem2',
        groupId: 'g5',
        storeId: 'storeB',
        addedAt: 0,
        addedByUid: 'owner',
      ));
      expect(
          (await db.storeGroupsDao.watchGroupsForStore('storeB').first).length,
          1);

      await db.storeGroupsDao.removeMember('g5', 'storeB');
      expect(
          await db.storeGroupsDao.watchGroupsForStore('storeB').first, isEmpty);
    });

    test('watchGroupsForStore returns empty when store has no groups',
        () async {
      final groups =
          await db.storeGroupsDao.watchGroupsForStore('lonely').first;
      expect(groups, isEmpty);
    });
  });
}
