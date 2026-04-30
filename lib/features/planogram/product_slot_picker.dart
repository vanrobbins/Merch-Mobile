import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../product_catalog/catalog_provider.dart';
import 'planogram_provider.dart';

/// Signature for the editor callback: productId, name, sku, category, optional colorHex.
typedef SlotAssignCallback = void Function(
  String productId,
  String name,
  String sku,
  String category, {
  String? colorHex,
});

class ProductSlotPicker extends ConsumerStatefulWidget {
  const ProductSlotPicker({
    super.key,
    this.planogramId,
    this.slotId,
    this.onAssign,
  }) : assert(
            (planogramId != null && slotId != null) || onAssign != null,
            'Provide either planogramId+slotId or onAssign callback');

  final String? planogramId;
  final String? slotId;
  final SlotAssignCallback? onAssign;

  /// Legacy detail-screen usage.
  static Future<void> showLegacy(
    BuildContext context,
    String planogramId,
    String slotId,
  ) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProductSlotPicker(
          planogramId: planogramId,
          slotId: slotId,
        ),
      );

  /// Editor usage — result delivered via callback.
  static Future<void> show(
    BuildContext context, {
    required String planogramId,
    required SlotAssignCallback onAssign,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            ProductSlotPicker(planogramId: planogramId, onAssign: onAssign),
      );

  @override
  ConsumerState<ProductSlotPicker> createState() =>
      _ProductSlotPickerState();
}

class _ProductSlotPickerState extends ConsumerState<ProductSlotPicker> {
  String _query = '';
  String? _selectedGender; // null = All

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusLg)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
            // Gender filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, 0),
              child: Row(
                children: [
                  const Text(
                    'GENDER:',
                    style: TextStyle(
                      fontSize: DesignTokens.typeXs,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _GenderChip(
                            label: 'All',
                            selected: _selectedGender == null,
                            onTap: () => setState(() => _selectedGender = null),
                          ),
                          const SizedBox(width: 4),
                          _GenderChip(
                            label: 'Men',
                            selected: _selectedGender == 'male',
                            onTap: () => setState(() => _selectedGender = 'male'),
                          ),
                          const SizedBox(width: 4),
                          _GenderChip(
                            label: 'Women',
                            selected: _selectedGender == 'female',
                            onTap: () => setState(() => _selectedGender = 'female'),
                          ),
                          const SizedBox(width: 4),
                          _GenderChip(
                            label: 'Unisex',
                            selected: _selectedGender == 'unisex',
                            onTap: () => setState(() => _selectedGender = 'unisex'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final q = _query.trim().toLowerCase();
                  var filtered = q.isEmpty
                      ? products
                      : products
                          .where((p) =>
                              p.name.toLowerCase().contains(q) ||
                              p.sku.toLowerCase().contains(q))
                          .toList();
                  if (_selectedGender != null) {
                    filtered = filtered
                        .where((p) => p.gender == _selectedGender)
                        .toList();
                  }
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No matching products',
                          style:
                              TextStyle(color: AppTheme.textSecondary)));
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return ListTile(
                        title: Text(p.name,
                            style: const TextStyle(
                                fontWeight: DesignTokens.weightMedium)),
                        subtitle: Text('SKU: ${p.sku}',
                            style: const TextStyle(
                                fontSize: DesignTokens.typeXs,
                                color: AppTheme.textSecondary)),
                        trailing: ElevatedButton(
                          onPressed: () => _assign(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppTheme.borderRadius)),
                            ),
                          ),
                          child: const Text('ASSIGN'),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assign(Product product) async {
    if (widget.onAssign != null) {
      // Editor callback path
      widget.onAssign!(product.id, product.name, product.sku, product.category);
      if (mounted) Navigator.pop(context);
      return;
    }
    // Legacy path
    final editor = ref.read(
        planogramEditorProvider(widget.planogramId!).notifier);
    editor.assignProduct(
        widget.slotId!, product.id, product.name, product.sku);
    await editor.save(widget.planogramId!);
    if (mounted) Navigator.pop(context);
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.surfaceVariant,
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
