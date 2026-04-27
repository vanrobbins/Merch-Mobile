import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  ZonesTableCompanion zone(String id, String storeId) =>
      ZonesTableCompanion.insert(
        id: id,
        name: 'Zone $id',
        colorValue: 0xFF3B6BC2,
        zoneType: 'display',
        storeId: storeId,
        updatedAt: DateTime(2025),
      );

  group('ZonesDao', () {
    test('insert and watchAll emits the row', () async {
      await db.zonesDao.upsert(zone('z1', 'default'));
      final rows = await db.zonesDao.watchAll().first;
      expect(rows.length, 1);
      expect(rows.first.name, 'Zone z1');
    });

    test('upsert updates existing row', () async {
      await db.zonesDao.upsert(zone('z1', 'default'));
      await db.zonesDao.upsert(
          zone('z1', 'default').copyWith(name: const Value('NEW')));
      final rows = await db.zonesDao.watchAll().first;
      expect(rows.first.name, 'NEW');
    });

    test('deleteById removes the row', () async {
      await db.zonesDao.upsert(zone('z1', 'default'));
      await db.zonesDao.deleteById('z1');
      final rows = await db.zonesDao.watchAll().first;
      expect(rows, isEmpty);
    });

    test('watchByStore returns only zones for that store', () async {
      await db.zonesDao.upsert(zone('z1', 'store_a'));
      await db.zonesDao.upsert(zone('z2', 'store_b'));
      await db.zonesDao.upsert(zone('z3', 'store_a'));

      final zones = await db.zonesDao.watchByStore('store_a').first;
      expect(zones.length, 2);
      expect(zones.every((z) => z.storeId == 'store_a'), isTrue);
    });

    test('watchByParentId is an alias for watchByStore', () async {
      await db.zonesDao.upsert(zone('z1', 'sX'));
      final zones = await db.zonesDao.watchByParentId('sX').first;
      expect(zones.length, 1);
      expect(zones.first.storeId, 'sX');
    });

    test('upsert persists shapePoints JSON', () async {
      await db.zonesDao.upsert(zone('z4', 'store_a').copyWith(
        shapePoints: const Value('[{"x":0.1,"y":0.1}]'),
      ));
      final z = await db.zonesDao.findById('z4');
      expect(z!.shapePoints, '[{"x":0.1,"y":0.1}]');
    });

    test('findById returns null for missing row', () async {
      final z = await db.zonesDao.findById('ghost');
      expect(z, isNull);
    });
  });
}
