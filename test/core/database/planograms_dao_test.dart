import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  PlanogramsTableCompanion planogram(
    String id, {
    String storeId = 'store_a',
    String fixtureId = 'f1',
    String title = 'Plano',
    String season = 'SS25',
    String status = 'draft',
    DateTime? updatedAt,
  }) =>
      PlanogramsTableCompanion.insert(
        id: id,
        fixtureId: fixtureId,
        title: title,
        season: season,
        updatedAt: updatedAt ?? DateTime(2025),
        storeId: Value(storeId),
        status: Value(status),
      );

  group('PlanogramsDao', () {
    test('upsert + findById returns planogram', () async {
      await db.planogramsDao.upsert(planogram('pl1'));
      final found = await db.planogramsDao.findById('pl1');
      expect(found, isNotNull);
      expect(found!.title, 'Plano');
    });

    test('watchByStore filters by store and orders by updatedAt desc',
        () async {
      await db.planogramsDao.upsert(
          planogram('pl1', storeId: 'sa', updatedAt: DateTime(2025, 1, 1)));
      await db.planogramsDao.upsert(
          planogram('pl2', storeId: 'sa', updatedAt: DateTime(2025, 3, 1)));
      await db.planogramsDao.upsert(
          planogram('pl3', storeId: 'sa', updatedAt: DateTime(2025, 2, 1)));
      await db.planogramsDao.upsert(
          planogram('pl4', storeId: 'sb', updatedAt: DateTime(2025, 4, 1)));

      final rows = await db.planogramsDao.watchByStore('sa').first;
      expect(rows.map((p) => p.id).toList(), ['pl2', 'pl3', 'pl1']);
    });

    test('watchByParentId filters by fixtureId (legacy alias)', () async {
      await db.planogramsDao.upsert(planogram('pl1', fixtureId: 'fA'));
      await db.planogramsDao.upsert(planogram('pl2', fixtureId: 'fB'));
      final rows = await db.planogramsDao.watchByParentId('fA').first;
      expect(rows.length, 1);
      expect(rows.first.id, 'pl1');
    });

    test('upsert updates existing planogram', () async {
      await db.planogramsDao.upsert(planogram('pl1', title: 'Old'));
      await db.planogramsDao.upsert(planogram('pl1', title: 'New'));
      final found = await db.planogramsDao.findById('pl1');
      expect(found!.title, 'New');
    });

    test('deleteById removes planogram', () async {
      await db.planogramsDao.upsert(planogram('pl1'));
      await db.planogramsDao.deleteById('pl1');
      expect(await db.planogramsDao.findById('pl1'), isNull);
    });
  });
}
