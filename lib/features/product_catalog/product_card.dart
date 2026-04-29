import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_card.dart';
import '../../core/widgets/role_guard.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.onTap, this.colorHex});

  final Product product;
  final VoidCallback? onTap;
  final String? colorHex; // hex like '#FF0000'

  String? get _silhouette => product.templateId?.replaceFirst('builtin_', '');

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
                        color: AppTheme.surfaceVariant,
                        child: _silhouette != null
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: SvgPicture.asset(
                                  'assets/silhouettes/$_silhouette.svg',
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.textHint,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppTheme.textHint,
                                  size: DesignTokens.iconMd,
                                ),
                              ),
                      ),
                    ),
                    RoleGuard(
                      allowedRoles: const ['coordinator', 'manager'],
                      child: Positioned(
                        top: DesignTokens.spaceXs,
                        right: DesignTokens.spaceXs,
                        child: _StockDot(inStock: product.stockQty > 0),
                      ),
                    ),
                  ],
                ),
              ),
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
                    if (product.price != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '\$${product.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: DesignTokens.typeXs,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Color strip at very bottom
              if (colorHex != null)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _parseHex(colorHex!),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(DesignTokens.radiusSm),
                      bottomRight: Radius.circular(DesignTokens.radiusSm),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _parseHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  final full = clean.length == 6 ? 'FF$clean' : clean;
  return Color(int.tryParse('0x$full') ?? 0xFF888888);
}

class _StockDot extends StatelessWidget {
  const _StockDot({required this.inStock});
  final bool inStock;

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: inStock ? AppTheme.successColor : AppTheme.errorColor,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
}
