import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  StoresTableCompanion _store({
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
      await db.storesDao.upsert(_store(
        id: 'store1',
        name: 'Test Store',
        inviteCode: 'ABC123',
      ));
      final store = await db.storesDao.findById('store1');
      expect(store, isNotNull);
      expect(store!.name, 'Test Store');
      expect(store.inviteCode, 'ABC123');
    });

    test('findByInviteCode returns correct store', () async {
      await db.storesDao.upsert(_store(
        id: 'store2',
        name: 'Another Store',
        inviteCode: 'XYZ789',
        createdAt: 2000,
        ownerUid: 'user2',
      ));
      final store = await db.storesDao.findByInviteCode('XYZ789');
      expect(store, isNotNull);
      expect(store!.id, 'store2');
    });

    test('findByInviteCode returns null for invalid code', () async {
      final store = await db.storesDao.findByInviteCode('NOPE00');
      expect(store, isNull);
    });

    test('deleteById removes store', () async {
      await db.storesDao.upsert(_store(
        id: 'store3',
        inviteCode: 'DEL001',
        createdAt: 3000,
      ));
      await db.storesDao.deleteById('store3');
      final store = await db.storesDao.findById('store3');
      expect(store, isNull);
    });

    test('upsert updates existing store', () async {
      await db.storesDao.upsert(_store(
        id: 'store4',
        name: 'Old Name',
        inviteCode: 'UPD001',
        createdAt: 4000,
      ));
      await db.storesDao.upsert(_store(
        id: 'store4',
        name: 'New Name',
        inviteCode: 'UPD001',
        createdAt: 4000,
      ));
      final store = await db.storesDao.findById('store4');
      expect(store!.name, 'New Name');
    });

    test('watchAll emits all stores', () async {
      await db.storesDao.upsert(_store(id: 's1', inviteCode: 'AAA001'));
      await db.storesDao.upsert(_store(id: 's2', inviteCode: 'BBB002'));
      final stores = await db.storesDao.watchAll().first;
      expect(stores.length, 2);
    });

    test('findById returns null for missing id', () async {
      final store = await db.storesDao.findById('missing');
      expect(store, isNull);
    });

    test('watchById emits the matching store', () async {
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's1', name: 'Store One', inviteCode: 'CODE1', createdAt: 1000, ownerUid: 'u1',
      ));
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's2', name: 'Store Two', inviteCode: 'CODE2', createdAt: 2000, ownerUid: 'u2',
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
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's1', name: 'Store One', inviteCode: 'CODE1', createdAt: 1000, ownerUid: 'u1',
      ));
      await db.storesDao.updateDimensions('s1', 60.0, 40.0);
      final store = await db.storesDao.findById('s1');
      expect(store, isNotNull);
      expect(store!.widthFt, 60.0);
      expect(store.depthFt, 40.0);
    });

    test('updateDimensions does not affect other stores', () async {
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's1', name: 'Store One', inviteCode: 'CODE1', createdAt: 1000, ownerUid: 'u1',
      ));
      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: 's2', name: 'Store Two', inviteCode: 'CODE2', createdAt: 2000, ownerUid: 'u2',
      ));
      await db.storesDao.updateDimensions('s1', 60.0, 40.0);
      final s2 = await db.storesDao.findById('s2');
      expect(s2!.widthFt, isNull);
      expect(s2.depthFt, isNull);
    });
  });
}
