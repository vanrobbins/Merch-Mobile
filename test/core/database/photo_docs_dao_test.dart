import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  PhotoDocsTableCompanion photo(
    String id, {
    String fixtureId = 'f1',
    String phase = 'before',
    String localPath = '/tmp/p.jpg',
    String storeId = 'store_a',
    DateTime? capturedAt,
    DateTime? updatedAt,
  }) =>
      PhotoDocsTableCompanion.insert(
        id: id,
        fixtureId: fixtureId,
        phase: phase,
        localPath: localPath,
        capturedAt: capturedAt ?? DateTime(2025),
        updatedAt: updatedAt ?? DateTime(2025),
        storeId: Value(storeId),
      );

  group('PhotoDocsDao', () {
    test('upsert + watchAll emits the row', () async {
      await db.photoDocsDao.upsert(photo('ph1'));
      final rows = await db.photoDocsDao.watchAll().first;
      expect(rows.length, 1);
      expect(rows.first.id, 'ph1');
    });

    test('watchByParentId filters by fixtureId', () async {
      await db.photoDocsDao.upsert(photo('ph1', fixtureId: 'fA'));
      await db.photoDocsDao.upsert(photo('ph2', fixtureId: 'fB'));
      await db.photoDocsDao.upsert(photo('ph3', fixtureId: 'fA'));

      final rows = await db.photoDocsDao.watchByParentId('fA').first;
      expect(rows.length, 2);
      expect(rows.every((r) => r.fixtureId == 'fA'), isTrue);
    });

    test('upsert updates existing photo', () async {
      await db.photoDocsDao.upsert(photo('ph1', phase: 'before'));
      await db.photoDocsDao.upsert(photo('ph1', phase: 'after'));
      final rows = await db.photoDocsDao.watchAll().first;
      expect(rows.single.phase, 'after');
    });

    test('deleteById removes photo', () async {
      await db.photoDocsDao.upsert(photo('ph1'));
      await db.photoDocsDao.deleteById('ph1');
      final rows = await db.photoDocsDao.watchAll().first;
      expect(rows, isEmpty);
    });
  });
}
