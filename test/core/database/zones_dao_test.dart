import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => await db.close());

  group('ZonesDao', () {
    test('insert and watchAll emits the row', () async {
      final companion = ZonesTableCompanion(
        id: const Value('z1'), name: const Value('WOMENS'),
        colorValue: const Value(0xFF3B6BC2), zoneType: const Value('womens'),
        storeId: const Value('default'), updatedAt: Value(DateTime(2025)),
      );
      await db.zonesDao.upsert(companion);
      final rows = await db.zonesDao.watchAll().first;
      expect(rows.length, 1);
      expect(rows.first.name, 'WOMENS');
    });

    test('upsert updates existing row', () async {
      final companion = ZonesTableCompanion(
        id: const Value('z1'), name: const Value('OLD'),
        colorValue: const Value(0xFF000000), zoneType: const Value('test'),
        storeId: const Value('default'), updatedAt: Value(DateTime(2025)),
      );
      await db.zonesDao.upsert(companion);
      await db.zonesDao.upsert(companion.copyWith(name: const Value('NEW')));
      final rows = await db.zonesDao.watchAll().first;
      expect(rows.first.name, 'NEW');
    });

    test('deleteById removes the row', () async {
      final companion = ZonesTableCompanion(
        id: const Value('z1'), name: const Value('DEL'),
        colorValue: const Value(0xFF000000), zoneType: const Value('test'),
        storeId: const Value('default'), updatedAt: Value(DateTime(2025)),
      );
      await db.zonesDao.upsert(companion);
      await db.zonesDao.deleteById('z1');
      final rows = await db.zonesDao.watchAll().first;
      expect(rows, isEmpty);
    });
  });
}
