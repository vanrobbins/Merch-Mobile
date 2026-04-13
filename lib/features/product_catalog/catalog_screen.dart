import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_banner.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/mm_search_bar.dart';
import 'catalog_provider.dart';
import 'product_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogNotifierProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOnline = connectivityAsync.valueOrNull ?? false;

    // Unique categories from all products
    final allProducts = state.products;
    final categories = allProducts.map((p) => p.category).toSet().toList()
      ..sort();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(catalogNotifierProvider.notifier).refreshFromApi(),
        child: CustomScrollView(
          slivers: [
            // SliverAppBar with embedded search bar
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
                    isLoading: state.isLoading,
                    onSearch: (query) =>
                        ref.read(catalogNotifierProvider.notifier).search(query),
                  ),
                ),
              ),
            ),
            // Offline banner
            if (!isOnline)
              const SliverToBoxAdapter(
                child: MmBanner(
                  variant: BannerVariant.offline,
                  message: 'You are offline. Showing cached products.',
                ),
              ),
            // Category filter chips
            if (categories.isNotEmpty)
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
                      // "All" chip
                      _CategoryChip(
                        label: 'All',
                        selected: _selectedCategory == null,
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          ref
                              .read(catalogNotifierProvider.notifier)
                              .filterByCategory(null);
                        },
                      ),
                      const SizedBox(width: DesignTokens.spaceXs),
                      ...categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(
                              right: DesignTokens.spaceXs),
                          child: _CategoryChip(
                            label: cat,
                            selected: _selectedCategory == cat,
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              ref
                                  .read(catalogNotifierProvider.notifier)
                                  .filterByCategory(cat);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Product grid
            if (state.isLoading && state.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.products.isEmpty)
              const SliverFillRemaining(
                child: MmEmptyState(
                  icon: Icons.inventory_2_outlined,
                  headline: 'No Products',
                  body: 'No products match your search.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: DesignTokens.spaceSm,
                    mainAxisSpacing: DesignTokens.spaceSm,
                    childAspectRatio: 120 / 160,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: allProducts[index],
                    ),
                    childCount: allProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
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
