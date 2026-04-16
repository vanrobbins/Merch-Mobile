import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';

part 'catalog_provider.g.dart';

@riverpod
Stream<List<ProductsTableData>> catalogProducts(CatalogProductsRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return db.productsDao.watchByStore(storeId);
}

@riverpod
class CatalogSearch extends _$CatalogSearch {
  @override
  String build() => '';

  void update(String query) => state = query;
}
