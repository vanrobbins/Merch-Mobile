import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_card.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 160,
      child: MmCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(DesignTokens.radiusSm),
                      topRight: Radius.circular(DesignTokens.radiusSm),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 1),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _GreyPlaceholder(),
                          )
                        : _GreyPlaceholder(),
                  ),
                  // Stock badge
                  Positioned(
                    top: DesignTokens.spaceXs,
                    right: DesignTokens.spaceXs,
                    child: _StockDot(inStock: product.stockQty > 0),
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
                  // SKU
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
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spaceXs),
                    // Size chips
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: product.sizes
                          .take(4)
                          .map((s) => _SizeChip(size: s))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: DesignTokens.iconMd,
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

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.size});

  final String size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Text(
        size,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: DesignTokens.weightMedium,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
