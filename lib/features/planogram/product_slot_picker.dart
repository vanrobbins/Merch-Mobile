import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_provider.dart';

/// Modal bottom sheet that lets a coordinator or manager pick a product
/// to drop into a specific planogram slot. Writes the assignment through
/// [PlanogramEditor] and persists via `save()`.
class ProductSlotPicker extends ConsumerStatefulWidget {
  const ProductSlotPicker({
    super.key,
    required this.planogramId,
    required this.slotId,
  });

  final String planogramId;
  final String slotId;

  static Future<void> show(
    BuildContext context,
    String planogramId,
    String slotId,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductSlotPicker(
        planogramId: planogramId,
        slotId: slotId,
      ),
    );
  }

  @override
  ConsumerState<ProductSlotPicker> createState() => _ProductSlotPickerState();
}

class _ProductSlotPickerState extends ConsumerState<ProductSlotPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';

    final productsAsync = ref.watch(
      StreamProvider<List<ProductsTableData>>(
        (r) => db.productsDao.watchByStore(storeId),
      ),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
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
                        BorderRadius.circular(DesignTokens.radiusLg),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final q = _query.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? products
                      : products
                          .where((p) =>
                              p.name.toLowerCase().contains(q) ||
                              p.sku.toLowerCase().contains(q))
                          .toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching products',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return ListTile(
                        title: Text(
                          p.name,
                          style: const TextStyle(
                              fontWeight: DesignTokens.weightMedium),
                        ),
                        subtitle: Text(
                          'SKU: ${p.sku}',
                          style: const TextStyle(
                              fontSize: DesignTokens.typeXs,
                              color: AppTheme.textSecondary),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _assign(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
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

  Future<void> _assign(ProductsTableData product) async {
    final editor =
        ref.read(planogramEditorProvider(widget.planogramId).notifier);
    editor.assignProduct(
      widget.slotId,
      product.id,
      product.name,
      product.sku,
    );
    // Auto-save after each assignment so the list view stays accurate.
    await editor.save(widget.planogramId);
    if (mounted) Navigator.pop(context);
  }
}
