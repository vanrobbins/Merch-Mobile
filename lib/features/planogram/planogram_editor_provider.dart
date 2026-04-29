import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/planogram.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'pg_row.dart';
import 'planogram_provider.dart';
import 'planogram_slot.dart';

part 'planogram_editor_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PlanogramEditorState {
  final Planogram? planogram;
  final List<PgSlot> slots;
  final List<PgRow> rows;
  final bool canUndo;
  final bool canRedo;
  final bool hasUnsavedChanges;

  const PlanogramEditorState({
    this.planogram,
    this.slots = const [],
    this.rows = const [],
    this.canUndo = false,
    this.canRedo = false,
    this.hasUnsavedChanges = false,
  });

  PlanogramEditorState copyWith({
    Planogram? planogram,
    List<PgSlot>? slots,
    List<PgRow>? rows,
    bool? canUndo,
    bool? canRedo,
    bool? hasUnsavedChanges,
  }) =>
      PlanogramEditorState(
        planogram: planogram ?? this.planogram,
        slots: slots ?? this.slots,
        rows: rows ?? this.rows,
        canUndo: canUndo ?? this.canUndo,
        canRedo: canRedo ?? this.canRedo,
        hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      );
}

// ---------------------------------------------------------------------------
// Undo entry (record syntax for brevity)
// ---------------------------------------------------------------------------

typedef _HistoryEntry = ({
  String beforeSlots,
  String beforeRows,
  String afterSlots,
  String afterRows,
  String label,
});

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class PlanogramEditorNotifier extends _$PlanogramEditorNotifier {
  final List<_HistoryEntry> _undoStack = [];
  final List<_HistoryEntry> _redoStack = [];

  @override
  PlanogramEditorState build(String planogramId) {
    // Listen to the planogram doc and initialise slots/rows on first load.
    ref.listen(
      planogramDetailProvider(planogramId),
      (_, next) {
        final pg = next.value;
        if (pg == null) return;
        // Only sync if we don't have unsaved changes.
        if (!state.hasUnsavedChanges) {
          final slots = pg.slotsJson.isEmpty
              ? PgSlot.defaultGrid(pg.rows, pg.cols, pg.planogramType)
              : PgSlot.decodeList(pg.slotsJson);
          final rows = pg.rowsJson.isEmpty
              ? PgRow.defaults(pg.rows, pg.planogramType)
              : PgRow.decodeList(pg.rowsJson);
          state = state.copyWith(planogram: pg, slots: slots, rows: rows);
        } else {
          // Update planogram metadata only (title, type) without clobbering slots.
          state = state.copyWith(planogram: pg);
        }
      },
      fireImmediately: true,
    );

    return const PlanogramEditorState();
  }

  // -------------------------------------------------------------------------
  // Undo/redo helpers
  // -------------------------------------------------------------------------

  String _currentSlotsJson() => PgSlot.encodeList(state.slots);
  String _currentRowsJson() => PgRow.encodeList(state.rows);

  /// Wrap a mutation: capture before → mutate → record entry.
  void _record(String label, void Function() mutate) {
    final beforeSlots = _currentSlotsJson();
    final beforeRows = _currentRowsJson();
    mutate();
    final afterSlots = _currentSlotsJson();
    final afterRows = _currentRowsJson();
    final entry = (
      beforeSlots: beforeSlots,
      beforeRows: beforeRows,
      afterSlots: afterSlots,
      afterRows: afterRows,
      label: label,
    );
    if (_undoStack.length >= 20) _undoStack.removeAt(0);
    _undoStack.add(entry);
    _redoStack.clear();
    state = state.copyWith(
        canUndo: true, canRedo: false, hasUnsavedChanges: true);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final entry = _undoStack.removeLast();
    _redoStack.add(entry);
    state = state.copyWith(
      slots: PgSlot.decodeList(entry.beforeSlots),
      rows: PgRow.decodeList(entry.beforeRows),
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
      hasUnsavedChanges: true,
    );
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final entry = _redoStack.removeLast();
    _undoStack.add(entry);
    state = state.copyWith(
      slots: PgSlot.decodeList(entry.afterSlots),
      rows: PgRow.decodeList(entry.afterRows),
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
      hasUnsavedChanges: true,
    );
  }

  // -------------------------------------------------------------------------
  // Slot mutations
  // -------------------------------------------------------------------------

  void assignSlot(
      int row, int col, String productId, String name, String sku,
      {String? colorHex}) {
    _record('Assign slot', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.copyWith(
            productId: productId,
            productName: name,
            productSku: sku,
            colorHex: colorHex,
          );
        }).toList(),
      );
    });
  }

  void clearSlot(int row, int col) {
    _record('Clear slot', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.cleared();
        }).toList(),
      );
    });
  }

  void setSpanCols(int row, int col, int spanCols) {
    _record('Resize span (cols)', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.copyWith(spanCols: spanCols.clamp(1, 4));
        }).toList(),
      );
    });
  }

  void setSpanRows(int row, int col, int spanRows) {
    final maxRows = state.planogram?.rows ?? 4;
    _record('Resize span (rows)', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.copyWith(spanRows: spanRows.clamp(1, maxRows));
        }).toList(),
      );
    });
  }

  void cycleRotation(int row, int col) {
    _record('Rotate slot', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.copyWith(rotation: (s.rotation + 90) % 360);
        }).toList(),
      );
    });
  }

  void setPresentationMode(int row, int col, String mode) {
    _record('Set presentation', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.row != row || s.col != col) return s;
          return s.copyWith(presentationMode: mode);
        }).toList(),
      );
    });
  }

  void setRowType(int rowIndex, String rowType) {
    _record('Toggle row type', () {
      state = state.copyWith(
        rows: state.rows.map((r) {
          if (r.index != rowIndex) return r;
          return r.copyWith(rowType: rowType);
        }).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Persist
  // -------------------------------------------------------------------------

  Future<void> save() async {
    final pg = state.planogram;
    if (pg == null) return;
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await FirestoreRefs.planograms(storeId).doc(pg.id).update({
      'slotsJson': PgSlot.encodeList(state.slots),
      'rowsJson': PgRow.encodeList(state.rows),
      'updatedAt': Timestamp.now(),
    });
    state = state.copyWith(hasUnsavedChanges: false);
  }

  Future<void> updateTitle(String title) async {
    final pg = state.planogram;
    if (pg == null) return;
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await FirestoreRefs.planograms(storeId).doc(pg.id).update({
      'title': title,
      'updatedAt': Timestamp.now(),
    });
  }
}
