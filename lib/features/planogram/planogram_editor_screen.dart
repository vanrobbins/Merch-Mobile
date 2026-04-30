import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'bay_view.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';
import 'slot_cell_widget.dart';

// Quarter-height equivalent for legacy grid/bay views (1 spanQuarter = cellH/4).
const double _kLegacyCellW = 72.0;
const double _kLegacyCellH = 80.0;
// Each slot defaults to spanQuarters=4, so quarterHeight = cellH / 4.
const double _kQuarterH = _kLegacyCellH / 4;

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
            : BayView(planogramId: widget.planogramId),
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

    const cellW = _kLegacyCellW;
    const quarterH = _kQuarterH;

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
                  child: _ActiveSlotWrapper(
                    slot: slot,
                    isActive: isActive,
                    cellWidth: cellW,
                    quarterHeight: quarterH,
                    onTap: slot.items.isNotEmpty
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
// Active-slot wrapper — adds long-press + drag handles around SlotCellWidget.
// ---------------------------------------------------------------------------

class _ActiveSlotWrapper extends StatelessWidget {
  const _ActiveSlotWrapper({
    required this.slot,
    required this.isActive,
    required this.cellWidth,
    required this.quarterHeight,
    this.onTap,
    this.onLongPress,
    this.onSpanColsDrag,
    this.onSpanRowsDrag,
    this.onRotate,
  });

  final PgSlot slot;
  final bool isActive;
  final double cellWidth;
  final double quarterHeight;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<int>? onSpanColsDrag;
  final ValueChanged<int>? onSpanRowsDrag;
  final VoidCallback? onRotate;

  @override
  Widget build(BuildContext context) {
    final cellH = quarterHeight * slot.spanQuarters +
        (slot.spanQuarters - 1) * 2.0;

    Widget child = GestureDetector(
      onLongPress: onLongPress,
      child: SlotCellWidget(
        slot: slot,
        cellWidth: cellWidth,
        quarterHeight: quarterHeight,
        isActive: isActive,
        onPress: onTap,
      ),
    );

    if (!isActive) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        // Right edge — spanCols drag handle
        Positioned(
          right: -10,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              if (onSpanColsDrag == null) return;
              final newSpan =
                  (slot.spanCols + (d.delta.dx / cellWidth).round())
                      .clamp(1, 4);
              onSpanColsDrag!(newSpan);
            },
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
              child:
                  const Icon(Icons.chevron_right, size: 14, color: Colors.white),
            ),
          ),
        ),
        // Bottom edge — spanRows drag handle
        Positioned(
          left: 0,
          right: 0,
          bottom: -10,
          child: GestureDetector(
            onVerticalDragUpdate: (d) {
              if (onSpanRowsDrag == null) return;
              final newSpan =
                  (slot.spanRows + (d.delta.dy / cellH).round()).clamp(1, 6);
              onSpanRowsDrag!(newSpan);
            },
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
              child:
                  const Icon(Icons.expand_more, size: 14, color: Colors.white),
            ),
          ),
        ),
        // Top-right corner — rotation
        Positioned(
          right: -8,
          top: -8,
          child: GestureDetector(
            onTap: onRotate,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rotate_90_degrees_cw,
                  size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
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
