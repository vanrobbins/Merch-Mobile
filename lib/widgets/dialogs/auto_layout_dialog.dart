import 'package:flutter/material.dart';
import '../../models/garment_item.dart';
import '../../models/garment_type.dart';
import '../../models/color_variant.dart';
import '../../theme/app_theme.dart';
import '../painters/garment_painter.dart';
import 'add_garment_dialog.dart';

/// Dialog for the Auto-Layout wizard.
/// User enters their product list here, then the engine generates sections.
class AutoLayoutDialog extends StatefulWidget {
  const AutoLayoutDialog({super.key});

  @override
  State<AutoLayoutDialog> createState() => _AutoLayoutDialogState();
}

class _AutoLayoutDialogState extends State<AutoLayoutDialog> {
  final List<GarmentItem> _products = [];

  Future<void> _addProduct() async {
    final garment = await showDialog<GarmentItem>(
      context: context,
      builder: (_) => const AddGarmentDialog(),
    );
    if (garment != null) setState(() => _products.add(garment));
  }

  Future<void> _editProduct(int index) async {
    final garment = await showDialog<GarmentItem>(
      context: context,
      builder: (_) => AddGarmentDialog(initial: _products[index]),
    );
    if (garment != null) setState(() => _products[index] = garment);
  }

  void _removeProduct(int index) {
    setState(() => _products.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.outline)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Layout',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Add your products and let the app build the schematic',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Product list
            Expanded(
              child: _products.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _ProductRow(
                            item: _products[i],
                            onEdit: () => _editProduct(i),
                            onDelete: () => _removeProduct(i),
                          ),
                    ),
            ),

            // Add product button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppTheme.outline)),
              ),
              child: Column(
                children: [
                  if (_products.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppTheme.primary.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Will generate ${_estimateSections()} section(s) optimised for retail VM best practices.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _products.isEmpty
                              ? null
                              : () => Navigator.pop(context, _products),
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _estimateSections() {
    int count = 0;
    if (_products.any((p) => p.type.isHanging)) count++;
    if (_products.any((p) => p.colorways.length >= 3)) count++;
    if (_products.length > 4) count++;
    return count.clamp(1, 5).toString();
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 12),
          const Text(
            'No products added',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add products to auto-generate the schematic',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final GarmentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        children: [
          // Garment preview
          GarmentIllustration(
            type: item.type,
            color: item.colorways.isNotEmpty
                ? item.colorways.first.color
                : Colors.grey,
            width: 44,
            height: 44,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.type.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Colorway swatches
                Row(
                  children: item.colorways.take(6).map((cv) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message: cv.name,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: cv.color,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                                color: AppTheme.outline, width: 0.5),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
