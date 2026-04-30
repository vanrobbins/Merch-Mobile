import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';
import 'slot_item.dart';
import 'slot_sizing.dart';

class ProductAssignmentSheet extends ConsumerWidget {
  const ProductAssignmentSheet({
    super.key,
    required this.planogramId,
    required this.slot,
  });

  final String planogramId;
  final PgSlot slot;

  static void show(BuildContext context,
      {required String planogramId, required PgSlot slot}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductAssignmentSheet(
        planogramId: planogramId,
        slot: slot,
      ),
    );
  }

  static const _capacity = {'shoulder': 1, 'faceout': 6, 'ubar': 6};
  static const _typeLabel = {
    'shoulder': 'SHOULDER HOOK',
    'faceout': 'FACE-OUT HOOK',
    'ubar': 'U-BAR',
    'shelf': 'SHELF',
  };
  static const _typeColor = {
    'shoulder': Color(0xFF3A3735),
    'faceout': Color(0xFF2E6DA4),
    'ubar': Color(0xFFBF5534),
    'shelf': Color(0xFF6B6660),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(planogramEditorNotifierProvider(planogramId));
    final currentSlot = editorState.slots.firstWhere(
      (s) => s.col == slot.col && s.subRow == slot.subRow,
      orElse: () => slot,
    );
    final notifier =
        ref.read(planogramEditorNotifierProvider(planogramId).notifier);

    final cap = _capacity[currentSlot.nodeType];
    final isFull = cap != null && currentSlot.items.length >= cap;
    final rowHeight = editorState.rows.isNotEmpty
        ? editorState.rows[
                (currentSlot.subRow ~/ 4).clamp(0, editorState.rows.length - 1)]
            .heightIn
        : 24.0;

    String fitLabel = '';
    bool fitOk = true;
    if (currentSlot.items.isNotEmpty && currentSlot.nodeType != 'shelf') {
      final maxHang = currentSlot.items
          .map((i) => hangLength(i.category))
          .reduce((a, b) => a > b ? a : b);
      final available =
          (editorState.rows.length - currentSlot.subRow ~/ 4) * rowHeight;
      fitOk = available >= maxHang;
      fitLabel = fitOk
          ? '✓ Fits ($maxHang" in ${available.toInt()}" available)'
          : '✗ Won\'t fully fit ($maxHang" needed, ${available.toInt()}" available)';
    }

    final accentColor = _typeColor[currentSlot.nodeType] ?? AppTheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.35,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _typeLabel[currentSlot.nodeType] ??
                          currentSlot.nodeType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: accentColor,
                      ),
                    ),
                  ),
                  if (cap != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${currentSlot.items.length} / $cap',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 12),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...currentSlot.items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                      decoration: BoxDecoration(
                        color: AppTheme.canvasBg,
                        border: Border.all(color: const Color(0xFFD5D2CB)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          if (item.colorHex != null)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _hexColor(item.colorHex!),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    '${item.productSku} · ${hangLength(item.category)}"',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 16, color: Colors.red.shade400),
                            onPressed: () => notifier.removeItemFromSlot(
                                currentSlot.col, currentSlot.subRow, i),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (!isFull)
                    GestureDetector(
                      onTap: () => _openPicker(ctx, notifier, currentSlot),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD5D2CB)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: AppTheme.accent),
                            SizedBox(width: 6),
                            Text('Add product',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ),
                  if (fitLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: fitOk
                            ? const Color(0xFFF0FBF4)
                            : const Color(0xFFFFF3F3),
                        border: Border.all(
                            color: fitOk
                                ? const Color(0xFF6FCF97)
                                : Colors.red.shade300),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        fitLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: fitOk
                              ? const Color(0xFF2E7D32)
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      notifier.removeFixture(
                          currentSlot.col, currentSlot.subRow);
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'REMOVE FIXTURE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext ctx, PlanogramEditorNotifier notifier,
      PgSlot currentSlot) {
    ProductSlotPicker.show(
      ctx,
      planogramId: planogramId,
      onAssign: (productId, name, sku, category, {colorHex}) {
        notifier.addItemToSlot(
          currentSlot.col,
          currentSlot.subRow,
          SlotItem(
            productId: productId,
            productName: name,
            productSku: sku,
            category: category,
            colorHex: colorHex,
          ),
        );
      },
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
