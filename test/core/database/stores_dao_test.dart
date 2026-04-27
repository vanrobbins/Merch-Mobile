import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  StoresTableCompanion store({
    required String id,
    String name = 'Test Store',
    String inviteCode = 'AAA111',
    int createdAt = 1000,
    String ownerUid = 'user1',
  }) =>
      StoresTableCompanion.insert(
        id: id,
        name: name,
        inviteCode: inviteCode,
        createdAt: createdAt,
        ownerUid: ownerUid,
      );

  group('StoresDao', () {
    test('upsert and findById returns store', () async {
      await db.storesDao.upsert(store(
        id: 'store1',
        name: 'Test Store',
        inviteCode: 'ABC123',
      ));
      final result = await db.storesDao.findById('store1');
      expect(result, isNotNull);
      expect(result!.name, 'Test Store');
      expect(result.inviteCode, 'ABC123');
    });

    test('findByInviteCode returns correct store', () async {
      await db.storesDao.upsert(store(
        id: 'store2',
        name: 'Another Store',
        inviteCode: 'XYZ789',
        createdAt: 2000,
        ownerUid: 'user2',
      ));
      final result = await db.storesDao.findByInviteCode('XYZ789');
      expect(result, isNotNull);
      expect(result!.id, 'store2');
    });

    test('findByInviteCode returns null for invalid code', () async {
      final result = await db.storesDao.findByInviteCode('NOPE00');
      expect(result, isNull);
    });

    test('deleteById removes store', () async {
      await db.storesDao.upsert(store(id: 'store3', inviteCode: 'DEL001'));
      await db.storesDao.deleteById('store3');
      expect(await db.storesDao.findById('store3'), isNull);
    });

    test('upsert updates existing store', () async {
      await db.storesDao
          .upsert(store(id: 'store4', name: 'Old Name', inviteCode: 'UPD001'));
      await db.storesDao
          .upsert(store(id: 'store4', name: 'New Name', inviteCode: 'UPD001'));
      final result = await db.storesDao.findById('store4');
      expect(result!.name, 'New Name');
    });

    test('watchAll emits all stores', () async {
      await db.storesDao.upsert(store(id: 's1', inviteCode: 'AAA001'));
      await db.storesDao.upsert(store(id: 's2', inviteCode: 'BBB002'));
      final stores = await db.storesDao.watchAll().first;
      expect(stores.length, 2);
      expect(stores.map((s) => s.id).toSet(), equals({'s1', 's2'}));
    });

    test('findById returns null for missing id', () async {
      expect(await db.storesDao.findById('missing'), isNull);
    });

    test('watchById emits the matching store', () async {
      await db.storesDao
          .upsert(store(id: 's1', name: 'Store One', inviteCode: 'CODE1'));
      await db.storesDao.upsert(store(
        id: 's2',
        name: 'Store Two',
        inviteCode: 'CODE2',
        createdAt: 2000,
        ownerUid: 'u2',
      ));
      final result = await db.storesDao.watchById('s1').first;
      expect(result, isNotNull);
      expect(result!.name, 'Store One');
    });

    test('watchById emits null for unknown id', () async {
      final result = await db.storesDao.watchById('nonexistent').first;
      expect(result, isNull);
    });

    test('updateDimensions persists widthFt and depthFt', () async {
      await db.storesDao.upsert(store(id: 's1', inviteCode: 'CODE1'));
      await db.storesDao.updateDimensions('s1', 60.0, 40.0);
      final result = await db.storesDao.findById('s1');
      expect(result, isNotNull);
      expect(result!.widthFt, 60.0);
      expect(result.depthFt, 40.0);
    });

    test('updateDimensions does not affect other stores', () async {
      await db.storesDao.upsert(store(id: 's1', inviteCode: 'CODE1'));
      await db.storesDao.upsert(store(id: 's2', inviteCode: 'CODE2'));
      await db.storesDao.updateDimensions('s1', 60.0, 40.0);
      final s2 = await db.storesDao.findById('s2');
      expect(s2!.widthFt, isNull);
      expect(s2.depthFt, isNull);
    });
  });
}
