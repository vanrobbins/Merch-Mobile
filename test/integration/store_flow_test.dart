import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../helpers/test_database.dart';

/// End-to-end integration test for the store lifecycle:
/// coordinator creates a store -> staff finds by invite code -> staff submits a
/// pending join request -> coordinator approves -> staff has an active
/// membership. All flows are exercised through the DAOs as they would be
/// exercised by the notifiers/providers in the real app.
void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  group('store create → join → approve flow', () {
    test('full happy path', () async {
      // 1. Coordinator creates store.
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 'store1',
        name: 'My Store',
        inviteCode: 'OPEN01',
        createdAt: 1000,
        ownerUid: 'coord1',
      ));
      await db.storeMembershipsDao.upsert(
          StoreMembershipsTableCompanion.insert(
        id: 'mem_coord',
        storeId: 'store1',
        userUid: 'coord1',
        role: 'coordinator',
        displayName: 'Coordinator',
        status: 'active',
        joinedAt: 1000,
      ));

      // 2. Staff finds store by invite code.
      final store = await db.storesDao.findByInviteCode('OPEN01');
      expect(store, isNotNull);
      expect(store!.name, 'My Store');

      // 3. Staff submits join request (pending).
      await db.storeMembershipsDao.upsert(
          StoreMembershipsTableCompanion.insert(
        id: 'mem_staff',
        storeId: 'store1',
        userUid: 'staff1',
        role: 'staff',
        displayName: 'Staff Member',
        status: 'pending',
        joinedAt: 2000,
      ));

      // 4. Coordinator sees pending request.
      final pending = await db.storeMembershipsDao.watchPending('store1').first;
      expect(pending.length, 1);
      expect(pending.first.userUid, 'staff1');

      // 5. Coordinator approves (flip status -> active).
      final request = pending.first;
      await db.storeMembershipsDao.upsert(
        request.toCompanion(true).copyWith(status: const Value('active')),
      );

      // 6. Staff now has active membership.
      final active = await db.storeMembershipsDao.findActive('store1', 'staff1');
      expect(active, isNotNull);
      expect(active!.role, 'staff');
      expect(active.status, 'active');

      // 7. Pending queue is now empty.
      final pendingAfter =
          await db.storeMembershipsDao.watchPending('store1').first;
      expect(pendingAfter, isEmpty);
    });

    test('invalid invite code returns null', () async {
      final store = await db.storesDao.findByInviteCode('XXXXX');
      expect(store, isNull);
    });

    test('staff cannot join a store twice (upsert is idempotent)', () async {
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 'store2',
        name: 'Store 2',
        inviteCode: 'DUP001',
        createdAt: 0,
        ownerUid: 'c1',
      ));
      await db.storeMembershipsDao.upsert(
          StoreMembershipsTableCompanion.insert(
        id: 'dup1',
        storeId: 'store2',
        userUid: 'u1',
        role: 'staff',
        displayName: 'User',
        status: 'pending',
        joinedAt: 0,
      ));
      // Upsert same id again — should update, not create duplicate.
      await db.storeMembershipsDao.upsert(
          StoreMembershipsTableCompanion.insert(
        id: 'dup1',
        storeId: 'store2',
        userUid: 'u1',
        role: 'staff',
        displayName: 'User Updated',
        status: 'pending',
        joinedAt: 0,
      ));
      final pending = await db.storeMembershipsDao.watchPending('store2').first;
      expect(pending.length, 1);
      expect(pending.first.displayName, 'User Updated');
    });

    test('rejection removes user from pending without creating active',
        () async {
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 'store3',
        name: 'Store 3',
        inviteCode: 'REJ001',
        createdAt: 0,
        ownerUid: 'coord',
      ));
      await db.storeMembershipsDao.upsert(
          StoreMembershipsTableCompanion.insert(
        id: 'rej1',
        storeId: 'store3',
        userUid: 'spam',
        role: 'staff',
        displayName: 'Spam',
        status: 'pending',
        joinedAt: 0,
      ));
      // Coordinator rejects by updating status.
      final pending =
          (await db.storeMembershipsDao.watchPending('store3').first).single;
      await db.storeMembershipsDao.upsert(
        pending
            .toCompanion(true)
            .copyWith(status: const Value('rejected')),
      );

      final active =
          await db.storeMembershipsDao.findActive('store3', 'spam');
      expect(active, isNull);
      final stillPending =
          await db.storeMembershipsDao.watchPending('store3').first;
      expect(stillPending, isEmpty);
    });

    test('two stores can be joined by the same user independently', () async {
      // Two stores, each with distinct invite codes.
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 'storeA',
        name: 'Store A',
        inviteCode: 'CODEAA',
        createdAt: 0,
        ownerUid: 'oA',
      ));
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 'storeB',
        name: 'Store B',
        inviteCode: 'CODEBB',
        createdAt: 0,
        ownerUid: 'oB',
      ));

      // Same user joins both as staff and is approved in both.
      for (final storeId in const ['storeA', 'storeB']) {
        await db.storeMembershipsDao.upsert(
            StoreMembershipsTableCompanion.insert(
          id: 'mem_$storeId',
          storeId: storeId,
          userUid: 'mobileUser',
          role: 'staff',
          displayName: 'Mobile User',
          status: 'active',
          joinedAt: 0,
        ));
      }

      final all = await db.storeMembershipsDao.watchByUser('mobileUser').first;
      expect(all.length, 2);
      expect(all.map((m) => m.storeId).toSet(),
          containsAll(['storeA', 'storeB']));
    });
  });
}
