import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  FixturesTableCompanion fixture(
    String id, {
    String zoneId = 'z1',
    String storeId = 'store_a',
    String fixtureType = 'rack',
  }) =>
      FixturesTableCompanion.insert(
        id: id,
        zoneId: zoneId,
        fixtureType: fixtureType,
        updatedAt: DateTime(2025),
        storeId: Value(storeId),
      );

  group('FixturesDao', () {
    test('upsert + watchAll emits the row', () async {
      await db.fixturesDao.upsert(fixture('f1'));
      final rows = await db.fixturesDao.watchAll().first;
      expect(rows.length, 1);
      expect(rows.first.id, 'f1');
    });

    test('watchByStore filters to the store', () async {
      await db.fixturesDao.upsert(fixture('f1', storeId: 'a'));
      await db.fixturesDao.upsert(fixture('f2', storeId: 'b'));
      await db.fixturesDao.upsert(fixture('f3', storeId: 'a'));

      final a = await db.fixturesDao.watchByStore('a').first;
      expect(a.length, 2);
      expect(a.every((f) => f.storeId == 'a'), isTrue);
    });

    test('watchByZone filters on (store, zone) pair', () async {
      await db.fixturesDao
          .upsert(fixture('f1', storeId: 'a', zoneId: 'z1'));
      await db.fixturesDao
          .upsert(fixture('f2', storeId: 'a', zoneId: 'z2'));
      await db.fixturesDao
          .upsert(fixture('f3', storeId: 'b', zoneId: 'z1'));

      final az1 = await db.fixturesDao.watchByZone('a', 'z1').first;
      expect(az1.length, 1);
      expect(az1.first.id, 'f1');
    });

    test('watchByParentId only filters on zoneId (legacy alias)', () async {
      await db.fixturesDao
          .upsert(fixture('f1', storeId: 'a', zoneId: 'zShared'));
      await db.fixturesDao
          .upsert(fixture('f2', storeId: 'b', zoneId: 'zShared'));

      final rows = await db.fixturesDao.watchByParentId('zShared').first;
      expect(rows.length, 2);
    });

    test('upsert updates an existing fixture', () async {
      await db.fixturesDao
          .upsert(fixture('f1', fixtureType: 'rack'));
      await db.fixturesDao.upsert(FixturesTableCompanion.insert(
        id: 'f1',
        zoneId: 'z1',
        fixtureType: 'wall',
        updatedAt: DateTime(2025),
        storeId: const Value('store_a'),
      ));
      final rows = await db.fixturesDao.watchAll().first;
      expect(rows.single.fixtureType, 'wall');
    });

    test('deleteById removes fixture', () async {
      await db.fixturesDao.upsert(fixture('f1'));
      await db.fixturesDao.deleteById('f1');
      final rows = await db.fixturesDao.watchAll().first;
      expect(rows, isEmpty);
    });
  });
}
