import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';
import 'slot_cell_widget.dart';

class PlanogramEditorScreen extends ConsumerStatefulWidget {
  const PlanogramEditorScreen({super.key, required this.planogramId});
  final String planogramId;

  @override
  ConsumerState<PlanogramEditorScreen> createState() =>
      _PlanogramEditorScreenState();
}

class _PlanogramEditorScreenState
    extends ConsumerState<PlanogramEditorScreen> {
  // (row, col) of the currently active slot (-1,-1 = none)
  int _activeRow = -1;
  int _activeCol = -1;
  PersistentBottomSheetController? _sheetController;

  void _activateSlot(int row, int col) {
    setState(() {
      _activeRow = row;
      _activeCol = col;
    });
    _showActionSheet(row, col);
  }

  void _deactivate() {
    _sheetController?.close();
    _sheetController = null;
    setState(() {
      _activeRow = -1;
      _activeCol = -1;
    });
  }

  void _showActionSheet(int row, int col) {
    _sheetController?.close();
    _sheetController = Scaffold.of(context).showBottomSheet(
      (ctx) => _SlotActionSheet(
        planogramId: widget.planogramId,
        row: row,
        col: col,
        onDismiss: _deactivate,
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState =
        ref.watch(planogramEditorNotifierProvider(widget.planogramId));
    final pg = editorState.planogram;

    if (pg == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('EDIT PLANOGRAM')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isTableType = pg.planogramType == 'table';

    return GestureDetector(
      onTap: _deactivate,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => _editTitle(pg.title),
            child: Text(
              pg.title.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            Consumer(
              builder: (_, ref, __) {
                final canUndo = ref.watch(
                  planogramEditorNotifierProvider(widget.planogramId)
                      .select((s) => s.canUndo),
                );
                return IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: canUndo
                      ? () => ref
                          .read(planogramEditorNotifierProvider(
                                  widget.planogramId)
                              .notifier)
                          .undo()
                      : null,
                );
              },
            ),
            Consumer(
              builder: (_, ref, __) {
                final canRedo = ref.watch(
                  planogramEditorNotifierProvider(widget.planogramId)
                      .select((s) => s.canRedo),
                );
                return IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed: canRedo
                      ? () => ref
                          .read(planogramEditorNotifierProvider(
                                  widget.planogramId)
                              .notifier)
                          .redo()
                      : null,
                );
              },
            ),
            TextButton(
              onPressed: () => ref
                  .read(planogramEditorNotifierProvider(widget.planogramId)
                      .notifier)
                  .save(),
              child: const Text('SAVE',
                  style: TextStyle(color: AppTheme.accent)),
            ),
          ],
        ),
        body: isTableType
            ? _GridView(
                planogramId: widget.planogramId,
                editorState: editorState,
                activeRow: _activeRow,
                activeCol: _activeCol,
                onTapEmpty: (row, col) => _openPicker(row, col),
                onTapFilled: (row, col) => _openPicker(row, col),
                onLongPress: _activateSlot,
                onSpanCols: (row, col, v) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .setSpanCols(row, col, v),
                onSpanRows: (row, col, v) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .setSpanRows(row, col, v),
                onRotate: (row, col) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .cycleRotation(row, col),
              )
            : _BayView(
                planogramId: widget.planogramId,
                editorState: editorState,
                activeRow: _activeRow,
                activeCol: _activeCol,
                onTapEmpty: (row, col) => _openPicker(row, col),
                onTapFilled: (row, col) => _openPicker(row, col),
                onLongPress: _activateSlot,
                onRowTypeToggle: (rowIndex, rowType) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .setRowType(rowIndex, rowType),
                onSpanCols: (row, col, v) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .setSpanCols(row, col, v),
                onSpanRows: (row, col, v) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .setSpanRows(row, col, v),
                onRotate: (row, col) => ref
                    .read(planogramEditorNotifierProvider(widget.planogramId)
                        .notifier)
                    .cycleRotation(row, col),
              ),
      ),
    );
  }

  void _openPicker(int row, int col) {
    ProductSlotPicker.show(
      context,
      planogramId: widget.planogramId,
      onAssign: (productId, name, sku, category, {colorHex}) {
        ref
            .read(planogramEditorNotifierProvider(widget.planogramId)
                .notifier)
            .assignSlot(row, col, productId, name, sku,
                colorHex: colorHex);
      },
    );
  }

  void _editTitle(String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RENAME'),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white),
            child: const Text('RENAME'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref
          .read(planogramEditorNotifierProvider(widget.planogramId)
              .notifier)
          .updateTitle(result);
    }
  }
}

// ---------------------------------------------------------------------------
// Bay View (wall / shelf / rack)
// ---------------------------------------------------------------------------

class _BayView extends StatelessWidget {
  const _BayView({
    required this.planogramId,
    required this.editorState,
    required this.activeRow,
    required this.activeCol,
    required this.onTapEmpty,
    required this.onTapFilled,
    required this.onLongPress,
    required this.onRowTypeToggle,
    required this.onSpanCols,
    required this.onSpanRows,
    required this.onRotate,
  });

  final String planogramId;
  final PlanogramEditorState editorState;
  final int activeRow;
  final int activeCol;
  final void Function(int row, int col) onTapEmpty;
  final void Function(int row, int col) onTapFilled;
  final void Function(int row, int col) onLongPress;
  final void Function(int rowIndex, String rowType) onRowTypeToggle;
  final void Function(int row, int col, int v) onSpanCols;
  final void Function(int row, int col, int v) onSpanRows;
  final void Function(int row, int col) onRotate;

  @override
  Widget build(BuildContext context) {
    final rows = editorState.rows;
    final slots = editorState.slots;
    final pg = editorState.planogram;
    if (pg == null) return const SizedBox.shrink();

    const cellW = 72.0;
    const cellH = 80.0;

    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      itemCount: rows.length,
      itemBuilder: (_, rowIdx) {
        final pgRow = rows[rowIdx];
        final rowSlots = slots
            .where((s) => s.row == rowIdx)
            .toList()
          ..sort((a, b) => a.col.compareTo(b.col));

        // Build blocked-cell set for this row
        final blockedCols = <int>{};
        for (final s in rowSlots) {
          if (s.spanCols > 1) {
            for (int c = s.col + 1; c < s.col + s.spanCols; c++) {
              blockedCols.add(c);
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row header
            Row(
              children: [
                Text(
                  'ROW ${rowIdx + 1}',
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                // BAR / SHELF segmented toggle
                Row(
                  children: ['bar', 'shelf'].map((type) {
                    final selected = pgRow.rowType == type;
                    return GestureDetector(
                      onTap: () => onRowTypeToggle(rowIdx, type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primary
                              : const Color(0xFFEAE7E0),
                          border: Border.all(
                              color: const Color(0xFFD5D2CB)),
                          borderRadius: BorderRadius.horizontal(
                            left: type == 'bar'
                                ? const Radius.circular(2)
                                : Radius.zero,
                            right: type == 'shelf'
                                ? const Radius.circular(2)
                                : Radius.zero,
                          ),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: DesignTokens.letterSpacingEyebrow,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Visual divider: thin rod (bar) or thick plank (shelf)
            pgRow.rowType == 'bar'
                ? Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B6660),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 6),
            // Slot cells
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(pg.cols, (colIdx) {
                  if (blockedCols.contains(colIdx)) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SlotCellWidget(
                        slot: PgSlot(
                            id: '', position: 0, row: rowIdx, col: colIdx),
                        isActive: false,
                        isBlocked: true,
                        cellWidth: cellW,
                        cellHeight: cellH,
                        productType: null,
                      ),
                    );
                  }
                  final slot = rowSlots.firstWhere(
                    (s) => s.col == colIdx,
                    orElse: () => PgSlot(
                        id: 'slot_${rowIdx}_$colIdx',
                        position: rowIdx * pg.cols + colIdx + 1,
                        row: rowIdx,
                        col: colIdx),
                  );
                  final isActive =
                      activeRow == rowIdx && activeCol == colIdx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: SlotCellWidget(
                      slot: slot,
                      isActive: isActive,
                      isBlocked: false,
                      cellWidth: cellW,
                      cellHeight: cellH,
                      productType: null,
                      onTap: slot.productId != null
                          ? () => onTapFilled(rowIdx, colIdx)
                          : () => onTapEmpty(rowIdx, colIdx),
                      onLongPress: () => onLongPress(rowIdx, colIdx),
                      onSpanColsDrag: (v) => onSpanCols(rowIdx, colIdx, v),
                      onSpanRowsDrag: (v) => onSpanRows(rowIdx, colIdx, v),
                      onRotate: () => onRotate(rowIdx, colIdx),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Grid View (table only)
// ---------------------------------------------------------------------------

class _GridView extends StatelessWidget {
  const _GridView({
    required this.planogramId,
    required this.editorState,
    required this.activeRow,
    required this.activeCol,
    required this.onTapEmpty,
    required this.onTapFilled,
    required this.onLongPress,
    required this.onSpanCols,
    required this.onSpanRows,
    required this.onRotate,
  });

  final String planogramId;
  final PlanogramEditorState editorState;
  final int activeRow;
  final int activeCol;
  final void Function(int row, int col) onTapEmpty;
  final void Function(int row, int col) onTapFilled;
  final void Function(int row, int col) onLongPress;
  final void Function(int row, int col, int v) onSpanCols;
  final void Function(int row, int col, int v) onSpanRows;
  final void Function(int row, int col) onRotate;

  @override
  Widget build(BuildContext context) {
    final slots = editorState.slots;
    final pg = editorState.planogram;
    if (pg == null) return const SizedBox.shrink();

    const cellW = 72.0;
    const cellH = 80.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        children: List.generate(pg.rows, (rowIdx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(pg.cols, (colIdx) {
                final slot = slots.firstWhere(
                  (s) => s.row == rowIdx && s.col == colIdx,
                  orElse: () => PgSlot(
                      id: 'slot_${rowIdx}_$colIdx',
                      position: rowIdx * pg.cols + colIdx + 1,
                      row: rowIdx,
                      col: colIdx,
                      presentationMode: 'folded'),
                );
                final isActive =
                    activeRow == rowIdx && activeCol == colIdx;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SlotCellWidget(
                    slot: slot,
                    isActive: isActive,
                    isBlocked: false,
                    cellWidth: cellW,
                    cellHeight: cellH,
                    productType: null,
                    onTap: slot.productId != null
                        ? () => onTapFilled(rowIdx, colIdx)
                        : () => onTapEmpty(rowIdx, colIdx),
                    onLongPress: () => onLongPress(rowIdx, colIdx),
                    onSpanColsDrag: (v) => onSpanCols(rowIdx, colIdx, v),
                    onSpanRowsDrag: (v) => onSpanRows(rowIdx, colIdx, v),
                    onRotate: () => onRotate(rowIdx, colIdx),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slot action sheet (non-blocking bottom sheet)
// ---------------------------------------------------------------------------

class _SlotActionSheet extends ConsumerWidget {
  const _SlotActionSheet({
    required this.planogramId,
    required this.row,
    required this.col,
    required this.onDismiss,
  });

  final String planogramId;
  final int row;
  final int col;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(
        planogramEditorNotifierProvider(planogramId));
    final slot = editorState.slots.firstWhere(
      (s) => s.row == row && s.col == col,
      orElse: () =>
          PgSlot(id: '', position: 0, row: row, col: col),
    );
    final notifier = ref.read(
        planogramEditorNotifierProvider(planogramId).notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Text('SLOT OPTIONS',
                style: TextStyle(
                  fontWeight: DesignTokens.weightBold,
                  letterSpacing: DesignTokens.letterSpacingEyebrow,
                  fontSize: DesignTokens.typeSm,
                )),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss),
          ]),
          const Divider(height: 12),
          // Presentation mode selector
          Row(
            children: ['face_out', 'shoulder_out', 'folded']
                .map((mode) {
                  final label = mode == 'face_out'
                      ? 'FACE'
                      : mode == 'shoulder_out'
                          ? 'SHOULDER'
                          : 'FOLDED';
                  final selected = slot.presentationMode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.setPresentationMode(row, col, mode),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.accent
                              : const Color(0xFFEAE7E0),
                          border: Border.all(
                              color: selected
                                  ? AppTheme.accent
                                  : const Color(0xFFD5D2CB)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: DesignTokens.letterSpacingEyebrow,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  notifier.cycleRotation(row, col);
                },
                icon: const Icon(Icons.rotate_90_degrees_cw, size: 16),
                label: const Text('ROTATE 90°'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  notifier.clearSlot(row, col);
                  onDismiss();
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('CLEAR SLOT'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade700),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
