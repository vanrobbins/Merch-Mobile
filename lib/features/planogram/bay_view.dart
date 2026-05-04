import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'fixture_picker_sheet.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_assignment_sheet.dart';
import 'slot_cell_widget.dart';

/// Seamless column-based planogram bay for wall/shelf/rack planogram types.
///
/// Two edit-mode interactions:
///   • Tap any empty cell → fixture picker opens → fixture placed there immediately.
///   • FAB "ADD FIXTURE" → picker opens → enters placement mode → tap cell to place.
class BayView extends ConsumerStatefulWidget {
  const BayView({super.key, required this.planogramId, this.isEditing = false});
  final String planogramId;
  final bool isEditing;

  @override
  ConsumerState<BayView> createState() => _BayViewState();
}

class _BayViewState extends ConsumerState<BayView> {
  static const double _cellWidth = 88.0;
  static const double _quarterHeight = 44.0;
  static const double _gap = 2.0;

  /// Set when the user picks a fixture type from the FAB picker (placement mode).
  /// null = no pending placement (direct-tap mode).
  String? _pendingNodeType;

  void _openFabPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FixturePickerSheet(
        onPick: (nodeType) => setState(() => _pendingNodeType = nodeType),
      ),
    );
  }

  void _onEmptyQuarterTap(int col, int subRow) {
    if (!widget.isEditing) return;
    if (_pendingNodeType != null) {
      // Placement mode: drop the pending type here.
      ref
          .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
          .placeFixture(col, subRow, _pendingNodeType!);
      setState(() => _pendingNodeType = null);
    } else {
      // Direct-tap mode: open picker and place immediately.
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => FixturePickerSheet(
          onPick: (nodeType) {
            ref
                .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
                .placeFixture(col, subRow, nodeType);
          },
        ),
      );
    }
  }

  void _onFixturePress(PgSlot slot) {
    if (!widget.isEditing) return;
    setState(() => _pendingNodeType = null);
    ProductAssignmentSheet.show(
      context,
      planogramId: widget.planogramId,
      slot: slot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editorState =
        ref.watch(planogramEditorNotifierProvider(widget.planogramId));
    final pg = editorState.planogram;
    if (pg == null) return const SizedBox.shrink();

    final slots = editorState.slots;
    final totalQuarters = pg.rows * 4;
    final totalHeight =
        totalQuarters * _quarterHeight + (totalQuarters - 1) * _gap;
    final isPlacementMode = widget.isEditing && _pendingNodeType != null;

    return Column(
      children: [
        // Placement-mode banner
        if (isPlacementMode)
          Material(
            color: AppTheme.accent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'TAP A CELL TO PLACE ${_pendingNodeType!.toUpperCase()}',
                    style: const TextStyle(
                      color: AppTheme.canvasBg,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _pendingNodeType = null),
                    child: const Icon(Icons.close,
                        color: AppTheme.canvasBg, size: 18),
                  ),
                ],
              ),
            ),
          ),
        // Planogram wall (scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(pg.cols, (col) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: SizedBox(
                      width: _cellWidth,
                      height: totalHeight,
                      child: _buildColumn(col, slots, totalQuarters, isPlacementMode),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        // ADD FIXTURE FAB (edit mode only)
        if (widget.isEditing)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                heroTag: 'bay_view_fab',
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.canvasBg,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'ADD FIXTURE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: _openFabPicker,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColumn(int col, List<PgSlot> slots, int totalQuarters,
      bool isPlacementMode) {
    final colSlots = slots
        .where((s) => s.col == col)
        .toList()
      ..sort((a, b) => a.subRow.compareTo(b.subRow));

    final widgets = <Widget>[];
    int current = 0;

    for (final slot in colSlots) {
      while (current < slot.subRow) {
        widgets.add(_emptyQuarterCell(col, current, isPlacementMode));
        current++;
      }
      widgets.add(SlotCellWidget(
        slot: slot,
        cellWidth: _cellWidth,
        quarterHeight: _quarterHeight,
        onPress: widget.isEditing ? () => _onFixturePress(slot) : null,
      ));
      current += slot.spanQuarters;
    }

    while (current < totalQuarters) {
      widgets.add(_emptyQuarterCell(col, current, isPlacementMode));
      current++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets
          .expand((w) => [w, const SizedBox(height: _gap)])
          .take(widgets.length * 2 - 1)
          .toList(),
    );
  }

  Widget _emptyQuarterCell(int col, int subRow, bool isPlacementMode) {
    final interactive = widget.isEditing;
    return GestureDetector(
      onTap: interactive ? () => _onEmptyQuarterTap(col, subRow) : null,
      child: Container(
        width: _cellWidth,
        height: _quarterHeight,
        decoration: BoxDecoration(
          color: isPlacementMode
              ? AppTheme.accent.withValues(alpha: 0.07)
              : Colors.transparent,
          border: Border.all(
            color: isPlacementMode
                ? AppTheme.accent.withValues(alpha: 0.35)
                : const Color(0x22393735),
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: interactive
            ? Center(
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: isPlacementMode
                      ? AppTheme.accent
                      : const Color(0x44393735),
                ),
              )
            : null,
      ),
    );
  }
}
