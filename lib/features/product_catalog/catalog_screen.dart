import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/product.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/seed_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_banner.dart';
import '../../core/widgets/mm_chip.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/mm_search_bar.dart';
import '../../core/widgets/role_guard.dart';
import 'catalog_provider.dart';
import 'product_card.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(catalogProductsProvider);
    final query = ref.watch(catalogSearchProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOnline = connectivityAsync.valueOrNull ?? false;

    return Scaffold(
      body: productsAsync.when(
        data: (List<Product> allProducts) {
          // Apply local search filter
          final filtered = query.isEmpty
              ? allProducts
              : allProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(query.toLowerCase()) ||
                      p.sku.toLowerCase().contains(query.toLowerCase()))
                  .toList();

          // Unique categories for chip filter
          final categories = allProducts.map((p) => p.category).toSet().toList()
            ..sort();

          return _CatalogBody(
            allProducts: allProducts,
            filtered: filtered,
            categories: categories,
            isOnline: isOnline,
            query: query,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: const ['coordinator', 'manager'],
        child: FloatingActionButton.extended(
          onPressed: () => context.goNamed(AppRoutes.productForm),
          label: const Text('ADD PRODUCT'),
          icon: const Icon(Icons.add),
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.canvasBg,
        ),
      ),
    );
  }
}

class _CatalogBody extends ConsumerStatefulWidget {
  const _CatalogBody({
    required this.allProducts,
    required this.filtered,
    required this.categories,
    required this.isOnline,
    required this.query,
  });

  final List<Product> allProducts;
  final List<Product> filtered;
  final List<String> categories;
  final bool isOnline;
  final String query;

  @override
  ConsumerState<_CatalogBody> createState() => _CatalogBodyState();
}

class _CatalogBodyState extends ConsumerState<_CatalogBody> {
  String? _selectedCategory;
  String? _selectedGender;
  bool _autoSeeded = false;

  List<Product> get _categoryFiltered {
    var products = widget.filtered;
    if (_selectedCategory != null) {
      products = products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }
    if (_selectedGender != null) {
      products = products
          .where((p) => p.gender == _selectedGender)
          .toList();
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = _categoryFiltered;
    final colorsAsync = ref.watch(brandColorsProvider);
    final colors = colorsAsync.valueOrNull ?? [];

    // Seed defaults once per store — guarded by `defaultsSeeded` flag on the store doc.
    // Users can delete seeded colors freely; the flag prevents re-seeding.
    if (!_autoSeeded && colorsAsync.hasValue) {
      _autoSeeded = true;
      final storeId = ref.read(activeStoreIdProvider).value;
      if (storeId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          maybeSeedDefaultStoreData(storeId);
        });
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 120,
          backgroundColor: AppTheme.primary,
          title: const Text('CATALOG'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings_outlined, color: AppTheme.canvasBg),
              onSelected: (value) {
                if (value == 'colors') {
                  context.goNamed(AppRoutes.colorPalette);
                } else if (value == 'templates') {
                  context.goNamed(AppRoutes.productTemplate);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'colors', child: Text('Color Palette')),
                PopupMenuItem(value: 'templates', child: Text('Product Templates')),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                0,
                DesignTokens.spaceMd,
                DesignTokens.spaceSm,
              ),
              child: MmSearchBar(
                hint: 'Search by name or SKU…',
                isLoading: false,
                onSearch: (q) =>
                    ref.read(catalogSearchProvider.notifier).update(q),
              ),
            ),
          ),
        ),
        if (!widget.isOnline)
          const SliverToBoxAdapter(
            child: MmBanner(
              variant: BannerVariant.offline,
              message: 'You are offline. Showing cached products.',
            ),
          ),
        if (widget.categories.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceXs,
                ),
                children: [
                  MmChip(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: DesignTokens.spaceXs),
                  ...widget.categories.map(
                    (cat) => Padding(
                      padding:
                          const EdgeInsets.only(right: DesignTokens.spaceXs),
                      child: MmChip(
                        label: cat,
                        selected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Gender filter row
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceXs,
              ),
              children: [
                MmChip(
                  label: 'All',
                  selected: _selectedGender == null,
                  onTap: () => setState(() => _selectedGender = null),
                ),
                const SizedBox(width: DesignTokens.spaceXs),
                MmChip(
                  label: 'Men',
                  selected: _selectedGender == 'male',
                  onTap: () => setState(() => _selectedGender = 'male'),
                ),
                const SizedBox(width: DesignTokens.spaceXs),
                MmChip(
                  label: 'Women',
                  selected: _selectedGender == 'female',
                  onTap: () => setState(() => _selectedGender = 'female'),
                ),
                const SizedBox(width: DesignTokens.spaceXs),
                MmChip(
                  label: 'Unisex',
                  selected: _selectedGender == 'unisex',
                  onTap: () => setState(() => _selectedGender = 'unisex'),
                ),
              ],
            ),
          ),
        ),
        if (displayProducts.isEmpty)
          SliverFillRemaining(
            child: MmEmptyState(
              icon: Icons.inventory_2_outlined,
              headline: 'No Products',
              body: widget.query.isEmpty && _selectedCategory == null && _selectedGender == null
                  ? 'No products yet.\nAdd your first product.'
                  : 'No products match your filter.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: DesignTokens.spaceSm,
                mainAxisSpacing: DesignTokens.spaceSm,
                childAspectRatio: 120 / 160,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = displayProducts[index];
                  final colorHex = product.colorId != null
                      ? colors.firstWhereOrNull((c) => c.id == product.colorId)?.hexValue
                      : null;
                  return ProductCard(
                    product: product,
                    colorHex: colorHex,
                    onTap: () => context.goNamed(
                      AppRoutes.productForm,
                      queryParameters: {'productId': product.id},
                    ),
                  );
                },
                childCount: displayProducts.length,
              ),
            ),
          ),
      ],
    );
  }
}

