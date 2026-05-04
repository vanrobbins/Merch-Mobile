import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/providers/store_provider.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_text_field.dart';
import '../../core/widgets/role_guard.dart';
import 'bay_view.dart';
import 'planogram_editor_provider.dart';
import 'planogram_look.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';
import 'slot_cell_widget.dart';

const double _kLegacyCellW = 72.0;
const double _kLegacyCellH = 80.0;
const double _kQuarterH = _kLegacyCellH / 4;

const _kEyebrowStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
  color: AppTheme.textSecondary,
);

const _kMannequinTypes = <(String, String, IconData)>[
  ('full_body', 'FULL BODY', Icons.accessibility_new_outlined),
  ('half_body', 'HALF BODY', Icons.person_outline),
  ('torso', 'TORSO', Icons.radio_button_unchecked),
  ('leg_form', 'LEG FORM', Icons.vertical_align_bottom_outlined),
  ('bra_form', 'BRA FORM', Icons.radio_button_checked),
  ('bag_stand', 'BAG STAND', Icons.shopping_bag_outlined),
  ('hat_stand', 'HAT STAND', Icons.hive_outlined),
];

/// Single planogram screen — view mode by default, EDIT button enters edit mode.
class PlanogramDetailScreen extends ConsumerStatefulWidget {
  const PlanogramDetailScreen({super.key, required this.planogramId});
  final String planogramId;

  @override
  ConsumerState<PlanogramDetailScreen> createState() =>
      _PlanogramDetailScreenState();
}

class _PlanogramDetailScreenState
    extends ConsumerState<PlanogramDetailScreen> {
  bool _isEditing = false;

  // Table-type grid editing state
  int _activeRow = -1;
  int _activeCol = -1;
  PersistentBottomSheetController? _sheetController;

  void _enterEdit() => setState(() => _isEditing = true);

  void _exitEdit() {
    _sheetController?.close();
    _sheetController = null;
    setState(() {
      _isEditing = false;
      _activeRow = -1;
      _activeCol = -1;
    });
  }

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

  void _openPicker(int row, int col) {
    ProductSlotPicker.show(
      context,
      planogramId: widget.planogramId,
      onAssign: (productId, name, sku, category, {colorHex}) {
        ref
            .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
            .assignSlot(row, col, productId, name, sku, colorHex: colorHex);
      },
    );
  }

  void _editTitle(String current) async {
    final ctrl = TextEditingController(text: current);
    String? result;
    await MmDialog.show<void>(
      context,
      title: 'RENAME',
      content: MmTextField(
        label: 'Title',
        controller: ctrl,
        autofocus: true,
        maxLength: 80,
      ),
      actions: [
        MmButton.outlined(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'RENAME',
          onPressed: () {
            result = ctrl.text.trim();
            Navigator.pop(context);
          },
        ),
      ],
    );
    if (result != null && result!.isNotEmpty && mounted) {
      await ref
          .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
          .updateTitle(result!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState =
        ref.watch(planogramEditorNotifierProvider(widget.planogramId));
    final pg = editorState.planogram;
    final membership = ref.watch(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';

    if (pg == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PLANOGRAM')),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final isTableType = pg.planogramType == 'table';
    final notifier =
        ref.read(planogramEditorNotifierProvider(widget.planogramId).notifier);

    return GestureDetector(
      onTap: (_isEditing && isTableType) ? _deactivate : null,
      child: Scaffold(
        appBar: _isEditing
            ? AppBar(
                automaticallyImplyLeading: false,
                leading: TextButton(
                  onPressed: _exitEdit,
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: AppTheme.canvasBg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: GestureDetector(
                  onTap: () => _editTitle(pg.title),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          pg.title.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.canvasBg),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_outlined, size: 14, color: AppTheme.textHint),
                    ],
                  ),
                ),
                actions: [
                  Consumer(
                    builder: (_, r, __) {
                      final canUndo = r.watch(
                        planogramEditorNotifierProvider(widget.planogramId)
                            .select((s) => s.canUndo),
                      );
                      return IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: 'Undo',
                        onPressed: canUndo ? notifier.undo : null,
                      );
                    },
                  ),
                  Consumer(
                    builder: (_, r, __) {
                      final canRedo = r.watch(
                        planogramEditorNotifierProvider(widget.planogramId)
                            .select((s) => s.canRedo),
                      );
                      return IconButton(
                        icon: const Icon(Icons.redo),
                        tooltip: 'Redo',
                        onPressed: canRedo ? notifier.redo : null,
                      );
                    },
                  ),
                ],
              )
            : AppBar(
                title: Text(pg.title.toUpperCase()),
                actions: [
                  _StatusChip(status: pg.status),
                  const SizedBox(width: 8),
                  RoleGuard(
                    allowedRoles: const ['coordinator', 'manager'],
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: AppTheme.canvasBg,
                      tooltip: 'Edit',
                      onPressed: _enterEdit,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rule_outlined, size: 20),
                    tooltip: 'Proposals',
                    onPressed: () => context.goNamed(
                      AppRoutes.proposalReview,
                      pathParameters: {'planogramId': widget.planogramId},
                    ),
                  ),
                ],
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: isTableType
                  ? _GridView(
                      planogramId: widget.planogramId,
                      editorState: editorState,
                      activeRow: _isEditing ? _activeRow : -1,
                      activeCol: _isEditing ? _activeCol : -1,
                      onTapEmpty: _isEditing ? _openPicker : (_, __) {},
                      onTapFilled: _isEditing ? _openPicker : (_, __) {},
                      onLongPress: _isEditing ? _activateSlot : (_, __) {},
                      onSpanCols: _isEditing
                          ? (r, c, v) => notifier.setSpanCols(r, c, v)
                          : (_, __, ___) {},
                      onSpanRows: _isEditing
                          ? (r, c, v) => notifier.setSpanRows(r, c, v)
                          : (_, __, ___) {},
                      onRotate: _isEditing
                          ? (r, c) => notifier.cycleRotation(r, c)
                          : (_, __) {},
                    )
                  : BayView(
                      planogramId: widget.planogramId,
                      isEditing: _isEditing,
                    ),
            ),
            _LooksStrip(
              planogramId: widget.planogramId,
              isEditing: _isEditing,
            ),
          ],
        ),
        floatingActionButton: (role == 'staff' && !_isEditing)
            ? FloatingActionButton.extended(
                onPressed: () => context.goNamed(
                  AppRoutes.planogramProposal,
                  pathParameters: {'planogramId': widget.planogramId},
                ),
                label: const Text('PROPOSE CHANGE'),
                icon: const Icon(Icons.edit_note),
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.canvasBg,
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid View (table-type planograms)
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
                    presentationMode: 'folded',
                  ),
                );
                final isActive = activeRow == rowIdx && activeCol == colIdx;
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
    final cellH =
        quarterHeight * slot.spanQuarters + (slot.spanQuarters - 1) * 2.0;

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
              child: const Icon(Icons.chevron_right,
                  size: 14, color: AppTheme.canvasBg),
            ),
          ),
        ),
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
              child: const Icon(Icons.expand_more,
                  size: 14, color: AppTheme.canvasBg),
            ),
          ),
        ),
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
                  size: 12, color: AppTheme.canvasBg),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Slot action sheet (non-blocking, table-type only)
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
    final editorState =
        ref.watch(planogramEditorNotifierProvider(planogramId));
    final slot = editorState.slots.firstWhere(
      (s) => s.row == row && s.col == col,
      orElse: () => PgSlot(id: '', position: 0, row: row, col: col),
    );
    final notifier =
        ref.read(planogramEditorNotifierProvider(planogramId).notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.15), blurRadius: 8)
        ],
      ),
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Text(
              'SLOT OPTIONS',
              style: TextStyle(
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                fontSize: DesignTokens.typeSm,
              ),
            ),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss),
          ]),
          const Divider(height: 12),
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
                      onTap: () =>
                          notifier.setPresentationMode(row, col, mode),
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.accent
                              : AppTheme.surfaceVariant,
                          border: Border.all(
                            color: selected
                                ? AppTheme.accent
                                : AppTheme.divider,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing:
                                DesignTokens.letterSpacingEyebrow,
                            color: selected
                                ? AppTheme.canvasBg
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
              child: MmButton.outlined(
                label: 'ROTATE 90°',
                icon: Icons.rotate_90_degrees_cw,
                onPressed: () => notifier.cycleRotation(row, col),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: MmButton.destructive(
                label: 'CLEAR SLOT',
                icon: Icons.clear,
                onPressed: () {
                  notifier.clearSlot(row, col);
                  onDismiss();
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outfit callouts strip
// ---------------------------------------------------------------------------

class _LooksStrip extends ConsumerWidget {
  const _LooksStrip({
    required this.planogramId,
    required this.isEditing,
  });

  final String planogramId;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState =
        ref.watch(planogramEditorNotifierProvider(planogramId));
    final looks = PlanogramLook.decodeList(
      editorState.planogram?.looksJson ?? '',
    );
    final notifier =
        ref.read(planogramEditorNotifierProvider(planogramId).notifier);

    if (!isEditing && looks.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.canvasBg,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OUTFIT CALLOUTS', style: _kEyebrowStyle),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...looks.map((look) => _LookCard(
                      look: look,
                      isEditing: isEditing,
                      onTap: () => _showEditSheet(context, look, notifier),
                      onRemove: () => notifier.removeLook(look.id),
                    )),
                if (isEditing)
                  _AddLookChip(
                    onTap: () => _showAddSheet(context, notifier),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, PlanogramEditorNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddLookSheet(notifier: notifier),
    );
  }

  void _showEditSheet(
    BuildContext context,
    PlanogramLook look,
    PlanogramEditorNotifier notifier,
  ) {
    if (!isEditing) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditLookSheet(look: look, notifier: notifier),
    );
  }
}

// ---------------------------------------------------------------------------
// Look card chip
// ---------------------------------------------------------------------------

class _LookCard extends StatelessWidget {
  const _LookCard({
    required this.look,
    required this.isEditing,
    required this.onTap,
    required this.onRemove,
  });

  final PlanogramLook look;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconForType(look.mannequinType),
                color: AppTheme.canvasBg, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  look.outfitName.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.canvasBg,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  look.mannequinType.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.canvasBg.withValues(alpha: 0.54),
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            if (isEditing) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close,
                    size: 12,
                    color: AppTheme.canvasBg.withValues(alpha: 0.54)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'full_body':
        return Icons.accessibility_new_outlined;
      case 'half_body':
        return Icons.person_outline;
      case 'torso':
        return Icons.radio_button_unchecked;
      case 'leg_form':
        return Icons.vertical_align_bottom_outlined;
      case 'bra_form':
        return Icons.radio_button_checked;
      case 'bag_stand':
        return Icons.shopping_bag_outlined;
      case 'hat_stand':
        return Icons.hive_outlined;
      default:
        return Icons.accessibility_new_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Add look chip
// ---------------------------------------------------------------------------

class _AddLookChip extends StatelessWidget {
  const _AddLookChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.accent),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 12, color: AppTheme.accent),
            SizedBox(width: 4),
            Text(
              'ADD LOOK',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add look sheet
// ---------------------------------------------------------------------------

class _AddLookSheet extends StatefulWidget {
  const _AddLookSheet({required this.notifier});
  final PlanogramEditorNotifier notifier;

  @override
  State<_AddLookSheet> createState() => _AddLookSheetState();
}

class _AddLookSheetState extends State<_AddLookSheet> {
  String _selectedType = 'full_body';
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusLg)),
        ),
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _handle(),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text(
              'ADD OUTFIT CALLOUT',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text('TYPE', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            _TypeChips(
              selected: _selectedType,
              onSelect: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text('OUTFIT NAME', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            MmTextField(
              hint: 'e.g. Summer Linen Look',
              controller: _nameCtrl,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            const Text('NOTES (optional)', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            MmTextField(
              hint: 'Styling notes...',
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            MmButton(
              label: 'ADD',
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context);
                await widget.notifier.addLook(
                  _selectedType,
                  name,
                  notes: _notesCtrl.text.trim(),
                );
              },
            ),
            SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    DesignTokens.spaceSm),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit look sheet
// ---------------------------------------------------------------------------

class _EditLookSheet extends StatefulWidget {
  const _EditLookSheet({required this.look, required this.notifier});
  final PlanogramLook look;
  final PlanogramEditorNotifier notifier;

  @override
  State<_EditLookSheet> createState() => _EditLookSheetState();
}

class _EditLookSheetState extends State<_EditLookSheet> {
  late String _selectedType;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.look.mannequinType;
    _nameCtrl = TextEditingController(text: widget.look.outfitName);
    _notesCtrl = TextEditingController(text: widget.look.notes);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusLg)),
        ),
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _handle(),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text(
              'EDIT OUTFIT CALLOUT',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text('TYPE', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            _TypeChips(
              selected: _selectedType,
              onSelect: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text('OUTFIT NAME', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            MmTextField(
              hint: 'e.g. Summer Linen Look',
              controller: _nameCtrl,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            const Text('NOTES (optional)', style: _kEyebrowStyle),
            const SizedBox(height: 6),
            MmTextField(
              hint: 'Styling notes...',
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            Row(
              children: [
                Expanded(
                  child: MmButton.destructive(
                    label: 'DELETE',
                    onPressed: () async {
                      Navigator.pop(context);
                      await widget.notifier.removeLook(widget.look.id);
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: MmButton(
                    label: 'SAVE',
                    onPressed: () async {
                      final name = _nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(context);
                      await widget.notifier.updateLook(
                        widget.look.id,
                        mannequinType: _selectedType,
                        outfitName: name,
                        notes: _notesCtrl.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    DesignTokens.spaceSm),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared type chip row
// ---------------------------------------------------------------------------

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _kMannequinTypes.map((t) {
        final isSelected = selected == t.$1;
        return GestureDetector(
          onTap: () => onSelect(t.$1),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.$3,
                    size: 12,
                    color: isSelected
                        ? AppTheme.canvasBg
                        : AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isSelected
                        ? AppTheme.canvasBg
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared handle bar for bottom sheets
// ---------------------------------------------------------------------------

Widget _handle() => Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    Color bg;
    switch (lower) {
      case 'published':
      case 'approved':
        bg = AppTheme.successColor;
        break;
      case 'rejected':
        bg = AppTheme.errorColor;
        break;
      case 'pending':
        bg = AppTheme.accent;
        break;
      default:
        bg = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.canvasBg,
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
        ),
      ),
    );
  }
}
