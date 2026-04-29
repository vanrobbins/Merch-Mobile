import 'package:flutter/material.dart';

import '../../core/models/mannequin_outfit_slot.dart';
import '../../core/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

/// A compact, read-only card that shows the current outfit state of a mannequin.
/// Pass the outfit name, the current [MannequinOutfitSlot] list, and the store's
/// [Product] list so each slot can be resolved to its SKU / name.
class MannequinLockCard extends StatelessWidget {
  const MannequinLockCard({
    super.key,
    required this.outfitName,
    required this.slots,
    required this.products,
  });

  final String outfitName;
  final List<MannequinOutfitSlot> slots;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final filled = slots.where((s) => s.productId != null).toList();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.divider),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outfit name
          Text(
            outfitName.isNotEmpty ? outfitName : 'UNNAMED OUTFIT',
            style: const TextStyle(
              fontSize: DesignTokens.typeMd,
              fontWeight: DesignTokens.weightBold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          if (filled.isEmpty)
            const Text(
              'No outfit',
              style: TextStyle(
                fontSize: DesignTokens.typeSm,
                color: AppTheme.textSecondary,
              ),
            )
          else ...[
            const Divider(height: DesignTokens.spaceMd),
            ...filled.map((slot) => _SlotLine(slot: slot, products: products)),
          ],
        ],
      ),
    );
  }
}

class _SlotLine extends StatelessWidget {
  const _SlotLine({required this.slot, required this.products});

  final MannequinOutfitSlot slot;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final product =
        products.where((p) => p.id == slot.productId).firstOrNull;

    final slotLabel =
        slot.bodySlot.replaceAll('_', ' ').toUpperCase();
    final productLabel = product != null
        ? '${product.sku} — ${product.name}'
        : slot.productId ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              slotLabel,
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(
            child: Text(
              productLabel,
              style: const TextStyle(
                fontSize: DesignTokens.typeSm,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
