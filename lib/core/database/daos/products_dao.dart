import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Stream<List<ProductsTableData>> watchAll() => select(productsTable).watch();

  Stream<List<ProductsTableData>> watchByParentId(String category) =>
      (select(productsTable)..where((t) => t.category.equals(category))).watch();

  Future<void> upsert(ProductsTableCompanion row) =>
      into(productsTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(productsTable)..where((t) => t.id.equals(id))).go();
}
