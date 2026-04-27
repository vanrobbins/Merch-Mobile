import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() async => await db.close());

  ProductsTableCompanion product(
    String id,
    String storeId, {
    String name = 'Product',
    String sku = 'SKU',
    String category = 'Tops',
  }) =>
      ProductsTableCompanion.insert(
        id: id,
        sku: '$sku-$id',
        name: '$name $id',
        category: category,
        updatedAt: DateTime(2025),
        storeId: Value(storeId),
      );

  group('ProductsDao', () {
    test('watchByStore returns only products for that store', () async {
      await db.productsDao.upsert(product('p1', 'sa'));
      await db.productsDao.upsert(product('p2', 'sb'));
      final products = await db.productsDao.watchByStore('sa').first;
      expect(products.length, 1);
      expect(products.first.id, 'p1');
    });

    test('watchByStore is ordered by name ascending', () async {
      await db.productsDao.upsert(product('p1', 'sa', name: 'Zeta'));
      await db.productsDao.upsert(product('p2', 'sa', name: 'Alpha'));
      await db.productsDao.upsert(product('p3', 'sa', name: 'Mu'));
      final products = await db.productsDao.watchByStore('sa').first;
      expect(products.map((p) => p.name).toList(),
          ['Alpha p2', 'Mu p3', 'Zeta p1']);
    });

    test('findById returns product', () async {
      await db.productsDao.upsert(product('p3', 'sa'));
      final p = await db.productsDao.findById('p3');
      expect(p, isNotNull);
      expect(p!.id, 'p3');
    });

    test('findById returns null for missing row', () async {
      expect(await db.productsDao.findById('missing'), isNull);
    });

    test('deleteById removes product', () async {
      await db.productsDao.upsert(product('p4', 'sa'));
      await db.productsDao.deleteById('p4');
      expect(await db.productsDao.findById('p4'), isNull);
    });

    test('searchByStore matches name substring', () async {
      await db.productsDao.upsert(product('p5', 'sa', name: 'Blue Shirt'));
      await db.productsDao.upsert(product('p6', 'sa', name: 'Red Pants'));
      final hits = await db.productsDao.searchByStore('sa', 'Blue');
      expect(hits.length, 1);
      expect(hits.first.id, 'p5');
    });

    test('searchByStore matches sku substring', () async {
      await db.productsDao
          .upsert(product('p7', 'sa', sku: 'UNIQUE'));
      final hits = await db.productsDao.searchByStore('sa', 'UNIQUE');
      expect(hits.length, 1);
      expect(hits.first.id, 'p7');
    });

    test('watchByParentId filters by category (legacy alias)', () async {
      await db.productsDao.upsert(product('p8', 'sa', category: 'Tops'));
      await db.productsDao.upsert(product('p9', 'sa', category: 'Bottoms'));
      final tops = await db.productsDao.watchByParentId('Tops').first;
      expect(tops.length, 1);
      expect(tops.first.id, 'p8');
    });
  });
}
