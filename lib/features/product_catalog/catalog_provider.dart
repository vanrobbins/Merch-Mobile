import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/models/product.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/api_client.dart';

part 'catalog_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CatalogState {
  final List<Product> products;
  final String searchQuery;
  final String? selectedCategory;
  final bool isLoading;
  final bool isOnline;

  const CatalogState({
    required this.products,
    this.searchQuery = '',
    this.selectedCategory,
    this.isLoading = false,
    this.isOnline = false,
  });

  CatalogState copyWith({
    List<Product>? products,
    String? searchQuery,
    Object? selectedCategory = _sentinel,
    bool? isLoading,
    bool? isOnline,
  }) =>
      CatalogState(
        products: products ?? this.products,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory == _sentinel
            ? this.selectedCategory
            : selectedCategory as String?,
        isLoading: isLoading ?? this.isLoading,
        isOnline: isOnline ?? this.isOnline,
      );
}

const _sentinel = Object();

// ---------------------------------------------------------------------------
// Row ↔ model conversions
// ---------------------------------------------------------------------------

Product _rowToProduct(ProductsTableData r) => Product(
      id: r.id,
      sku: r.sku,
      name: r.name,
      category: r.category,
      imageUrl: r.imageUrl,
      sizes: (jsonDecode(r.sizesJson) as List<dynamic>).cast<String>(),
      stockQty: r.stockQty,
      updatedAt: r.updatedAt,
    );

ProductsTableCompanion _productToCompanion(Product p) => ProductsTableCompanion(
      id: Value(p.id),
      sku: Value(p.sku),
      name: Value(p.name),
      category: Value(p.category),
      imageUrl: Value(p.imageUrl),
      sizesJson: Value(jsonEncode(p.sizes)),
      stockQty: Value(p.stockQty),
      updatedAt: Value(p.updatedAt),
    );

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  StreamSubscription<List<ProductsTableData>>? _sub;

  @override
  CatalogState build() {
    final db = ref.watch(appDatabaseProvider);

    // Watch connectivity state
    final connectivityStream = ref.watch(connectivityProvider);
    final isOnline = connectivityStream.value ?? false;

    _sub?.cancel();
    _sub = db.productsDao.watchAll().listen((rows) {
      final allProducts = rows.map(_rowToProduct).toList();
      state = state.copyWith(
        products: _applyLocalFilters(
          allProducts,
          state.searchQuery,
          state.selectedCategory,
        ),
        isLoading: false,
      );
    });
    ref.onDispose(() => _sub?.cancel());

    return CatalogState(
      products: const [],
      isLoading: true,
      isOnline: isOnline,
    );
  }

  // -------------------------------------------------------------------------
  // Search
  // -------------------------------------------------------------------------

  /// Online: fetches from API (and upserts results locally), then filters.
  /// Offline: filters the already-loaded local product list.
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);

    if (state.isOnline) {
      try {
        final remote = await ApiClient().getProducts(query: query);
        final db = ref.read(appDatabaseProvider);
        for (final product in remote) {
          await db.productsDao.upsert(_productToCompanion(product));
        }
        // The watchAll stream will update state.products automatically,
        // but apply filters immediately to the freshly fetched set.
        state = state.copyWith(
          products: _applyLocalFilters(remote, query, state.selectedCategory),
          isLoading: false,
        );
      } catch (_) {
        // Fall back to local filtering on API error
        state = state.copyWith(
          products: _applyLocalFilters(
            state.products,
            query,
            state.selectedCategory,
          ),
          isLoading: false,
        );
      }
    } else {
      // Offline: filter local products
      final db = ref.read(appDatabaseProvider);
      final rows = await db.productsDao.watchAll().first;
      final all = rows.map(_rowToProduct).toList();
      state = state.copyWith(
        products: _applyLocalFilters(all, query, state.selectedCategory),
        isLoading: false,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Category filter
  // -------------------------------------------------------------------------

  Future<void> filterByCategory(String? category) async {
    state = state.copyWith(
      selectedCategory: category,
      isLoading: true,
    );
    final db = ref.read(appDatabaseProvider);
    final rows = await db.productsDao.watchAll().first;
    final all = rows.map(_rowToProduct).toList();
    state = state.copyWith(
      products: _applyLocalFilters(all, state.searchQuery, category),
      isLoading: false,
    );
  }

  // -------------------------------------------------------------------------
  // API refresh
  // -------------------------------------------------------------------------

  Future<void> refreshFromApi() async {
    state = state.copyWith(isLoading: true);
    try {
      final remote = await ApiClient().getProducts();
      final db = ref.read(appDatabaseProvider);
      for (final product in remote) {
        await db.productsDao.upsert(_productToCompanion(product));
      }
      // watchAll stream will update state; update loading flag.
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  List<Product> _applyLocalFilters(
    List<Product> products,
    String query,
    String? category,
  ) {
    var result = products;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.sku.toLowerCase().contains(q),
          )
          .toList();
    }

    if (category != null) {
      result = result.where((p) => p.category == category).toList();
    }

    return result;
  }
}
