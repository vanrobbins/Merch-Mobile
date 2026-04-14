import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_card.dart';
import '../../core/widgets/role_guard.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final ProductsTableData product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 120,
      height: 160,
      child: GestureDetector(
        onTap: onTap,
        child: MmCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image placeholder
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(DesignTokens.radiusSm),
                        topRight: Radius.circular(DesignTokens.radiusSm),
                      ),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: DesignTokens.iconMd,
                          ),
                        ),
                      ),
                    ),
                    // Stock badge (coordinator/manager only)
                    RoleGuard(
                      allowedRoles: ['coordinator', 'manager'],
                      child: Positioned(
                        top: DesignTokens.spaceXs,
                        right: DesignTokens.spaceXs,
                        child: _StockDot(inStock: product.stockQty > 0),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom info
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceXs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.sku.toUpperCase(),
                      style: const TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: DesignTokens.typeSm,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockDot extends StatelessWidget {
  const _StockDot({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: inStock ? Colors.green.shade600 : Colors.red.shade600,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}
