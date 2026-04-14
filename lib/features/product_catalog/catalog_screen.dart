import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_banner.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/mm_search_bar.dart';
import '../../core/widgets/role_guard.dart';
import 'catalog_provider.dart';
import 'product_card.dart';
import 'product_form_screen.dart';

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
        data: (List<ProductsTableData> allProducts) {
          // Apply local search filter
          final filtered = query.isEmpty
              ? allProducts
              : allProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(query.toLowerCase()) ||
                      p.sku.toLowerCase().contains(query.toLowerCase()))
                  .toList();

          // Unique categories for chip filter
          final categories =
              allProducts.map((p) => p.category).toSet().toList()..sort();

          return _CatalogBody(
            allProducts: allProducts,
            filtered: filtered,
            categories: categories,
            isOnline: isOnline,
            query: query,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: ['coordinator', 'manager'],
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          ),
          label: const Text('ADD PRODUCT'),
          icon: const Icon(Icons.add),
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
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

  final List<ProductsTableData> allProducts;
  final List<ProductsTableData> filtered;
  final List<String> categories;
  final bool isOnline;
  final String query;

  @override
  ConsumerState<_CatalogBody> createState() => _CatalogBodyState();
}

class _CatalogBodyState extends ConsumerState<_CatalogBody> {
  String? _selectedCategory;

  List<ProductsTableData> get _categoryFiltered {
    if (_selectedCategory == null) return widget.filtered;
    return widget.filtered
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = _categoryFiltered;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 120,
          backgroundColor: AppTheme.primary,
          title: const Text('CATALOG'),
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
                  _CategoryChip(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: DesignTokens.spaceXs),
                  ...widget.categories.map(
                    (cat) => Padding(
                      padding:
                          const EdgeInsets.only(right: DesignTokens.spaceXs),
                      child: _CategoryChip(
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
        if (displayProducts.isEmpty)
          SliverFillRemaining(
            child: MmEmptyState(
              icon: Icons.inventory_2_outlined,
              headline: 'No Products',
              body: widget.query.isEmpty && _selectedCategory == null
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
                (context, index) => ProductCard(
                  product: displayProducts[index],
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(
                          productId: displayProducts[index].id),
                    ),
                  ),
                ),
                childCount: displayProducts.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: DesignTokens.typeXs,
            fontWeight: DesignTokens.weightBold,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
