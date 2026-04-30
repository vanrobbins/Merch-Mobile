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
/// Each column stacks fixtures freely at any quarter-slot position.
/// No row headers or dividers — the wall flows continuously.
class BayView extends ConsumerStatefulWidget {
  const BayView({super.key, required this.planogramId});
  final String planogramId;

  @override
  ConsumerState<BayView> createState() => _BayViewState();
}

class _BayViewState extends ConsumerState<BayView> {
  static const double _cellWidth = 80.0;
  static const double _quarterHeight = 20.0;
  static const double _gap = 2.0;

  String? _pendingNodeType;

  void _showFixturePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FixturePickerSheet(
        onPick: (nodeType) => setState(() => _pendingNodeType = nodeType),
      ),
    );
  }

  void _onEmptyQuarterTap(int col, int subRow) {
    if (_pendingNodeType == null) return;
    ref
        .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
        .placeFixture(col, subRow, _pendingNodeType!);
    setState(() => _pendingNodeType = null);
  }

  void _onFixturePress(PgSlot slot) {
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

    final isPendingPlacement = _pendingNodeType != null;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                    child: _buildColumn(
                        col, slots, totalQuarters, isPendingPlacement),
                  ),
                );
              }),
            ),
          ),
        ),
        if (isPendingPlacement)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: AppTheme.accent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'TAP A CELL TO PLACE ${_pendingNodeType!.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _pendingNodeType = null),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'bay_view_fab',
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'ADD FIXTURE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            onPressed: _showFixturePicker,
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
      int col, List<PgSlot> slots, int totalQuarters, bool isPendingPlacement) {
    final colSlots = slots
        .where((s) => s.col == col)
        .toList()
      ..sort((a, b) => a.subRow.compareTo(b.subRow));

    final widgets = <Widget>[];
    int current = 0;

    for (final slot in colSlots) {
      while (current < slot.subRow) {
        widgets.add(_emptyQuarterCell(col, current, isPendingPlacement));
        current++;
      }
      widgets.add(SlotCellWidget(
        slot: slot,
        cellWidth: _cellWidth,
        quarterHeight: _quarterHeight,
        onPress: () => _onFixturePress(slot),
      ));
      current += slot.spanQuarters;
    }

    while (current < totalQuarters) {
      widgets.add(_emptyQuarterCell(col, current, isPendingPlacement));
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

  Widget _emptyQuarterCell(int col, int subRow, bool isPendingPlacement) {
    return GestureDetector(
      onTap:
          isPendingPlacement ? () => _onEmptyQuarterTap(col, subRow) : null,
      child: Container(
        width: _cellWidth,
        height: _quarterHeight,
        decoration: BoxDecoration(
          color: isPendingPlacement
              ? AppTheme.accent.withValues(alpha: 0.07)
              : Colors.transparent,
          border: Border.all(
            color: isPendingPlacement
                ? AppTheme.accent.withValues(alpha: 0.35)
                : const Color(0x22393735),
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: isPendingPlacement
            ? const Center(
                child: Icon(Icons.add, size: 10, color: AppTheme.accent))
            : null,
      ),
    );
  }
}
