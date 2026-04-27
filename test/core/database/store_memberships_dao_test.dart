import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    // Seed a store so the membership rows have a plausible parent id.
    await db.storesDao.upsert(StoresTableCompanion.insert(
      id: 's1',
      name: 'Store',
      inviteCode: 'AAA111',
      createdAt: 0,
      ownerUid: 'u0',
    ));
  });
  tearDown(() async => await db.close());

  StoreMembershipsTableCompanion membership({
    required String id,
    required String userUid,
    String storeId = 's1',
    String role = 'staff',
    String status = 'pending',
    String? displayName,
    int joinedAt = 1000,
  }) =>
      StoreMembershipsTableCompanion.insert(
        id: id,
        storeId: storeId,
        userUid: userUid,
        role: role,
        displayName: displayName ?? 'User $userUid',
        status: status,
        joinedAt: joinedAt,
      );

  group('StoreMembershipsDao', () {
    test('watchPending returns only pending memberships', () async {
      await db.storeMembershipsDao
          .upsert(membership(id: 'm1', userUid: 'u1'));
      await db.storeMembershipsDao
          .upsert(membership(id: 'm2', userUid: 'u2', status: 'active'));

      final pending = await db.storeMembershipsDao.watchPending('s1').first;
      expect(pending.length, 1);
      expect(pending.first.id, 'm1');
    });

    test('findActive returns active membership for user', () async {
      await db.storeMembershipsDao
          .upsert(membership(id: 'm3', userUid: 'u3', status: 'active'));
      final found = await db.storeMembershipsDao.findActive('s1', 'u3');
      expect(found, isNotNull);
      expect(found!.role, 'staff');
    });

    test('findActive returns null for pending membership', () async {
      await db.storeMembershipsDao
          .upsert(membership(id: 'm4', userUid: 'u4'));
      final found = await db.storeMembershipsDao.findActive('s1', 'u4');
      expect(found, isNull);
    });

    test('findActive returns null when user has no membership', () async {
      final found = await db.storeMembershipsDao.findActive('s1', 'ghost');
      expect(found, isNull);
    });

    test('upsert updates status from pending to active', () async {
      await db.storeMembershipsDao
          .upsert(membership(id: 'm5', userUid: 'u5'));
      final before = await db.storeMembershipsDao.watchPending('s1').first;
      expect(before.any((m) => m.id == 'm5'), isTrue);

      await db.storeMembershipsDao.upsert(
          membership(id: 'm5', userUid: 'u5', status: 'active'));
      final after = await db.storeMembershipsDao.watchPending('s1').first;
      expect(after.any((m) => m.id == 'm5'), isFalse);

      final active = await db.storeMembershipsDao.findActive('s1', 'u5');
      expect(active, isNotNull);
    });

    test('watchByStore orders by joinedAt ascending', () async {
      await db.storeMembershipsDao.upsert(membership(
          id: 'm6', userUid: 'u6', status: 'active', joinedAt: 3000));
      await db.storeMembershipsDao.upsert(membership(
          id: 'm7', userUid: 'u7', status: 'active', joinedAt: 1000));
      await db.storeMembershipsDao.upsert(membership(
          id: 'm8', userUid: 'u8', status: 'active', joinedAt: 2000));

      final members = await db.storeMembershipsDao.watchByStore('s1').first;
      expect(members.map((m) => m.id).toList(), ['m7', 'm8', 'm6']);
    });

    test('watchByUser returns all memberships for a user', () async {
      // Seed a second store so one user can have two memberships.
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's2',
        name: 'Store 2',
        inviteCode: 'BBB222',
        createdAt: 0,
        ownerUid: 'u0',
      ));

      await db.storeMembershipsDao.upsert(membership(
          id: 'm9', userUid: 'u9', status: 'active'));
      await db.storeMembershipsDao.upsert(membership(
          id: 'm10',
          userUid: 'u9',
          storeId: 's2',
          status: 'pending'));

      final memberships = await db.storeMembershipsDao.watchByUser('u9').first;
      expect(memberships.length, 2);
    });

    test('deleteById removes membership', () async {
      await db.storeMembershipsDao
          .upsert(membership(id: 'm11', userUid: 'u11'));
      await db.storeMembershipsDao.deleteById('m11');
      final pending = await db.storeMembershipsDao.watchPending('s1').first;
      expect(pending.any((m) => m.id == 'm11'), isFalse);
    });
  });
}
