import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/planogram.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'pg_row.dart';
import 'planogram_provider.dart';
import 'planogram_slot.dart';
import 'slot_item.dart';
import 'slot_sizing.dart';

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
    // Listen for future planogram changes (e.g. remote title edits, status).
    // fireImmediately is intentionally omitted: it fires synchronously during
    // build() when the provider already has a cached value, which causes a
    // StateError because `state` is not yet initialised at that point.
    ref.listen(planogramDetailProvider(planogramId), (_, next) {
      final pg = next.value;
      if (pg == null) return;
      if (state.hasUnsavedChanges) {
        state = state.copyWith(planogram: pg);
      } else {
        final slots = pg.slotsJson.isEmpty
            ? PgSlot.defaultGrid(pg.rows, pg.cols, pg.planogramType)
            : PgSlot.decodeList(pg.slotsJson);
        final rows = pg.rowsJson.isEmpty
            ? PgRow.defaults(pg.rows, pg.planogramType)
            : PgRow.decodeList(pg.rowsJson);
        state = state.copyWith(planogram: pg, slots: slots, rows: rows);
      }
    });

    // Initialise synchronously from whatever value is already cached.
    final pg = ref.read(planogramDetailProvider(planogramId)).value;
    if (pg == null) return const PlanogramEditorState();
    final slots = pg.slotsJson.isEmpty
        ? PgSlot.defaultGrid(pg.rows, pg.cols, pg.planogramType)
        : PgSlot.decodeList(pg.slotsJson);
    final rows = pg.rowsJson.isEmpty
        ? PgRow.defaults(pg.rows, pg.planogramType)
        : PgRow.decodeList(pg.rowsJson);
    return PlanogramEditorState(planogram: pg, slots: slots, rows: rows);
  }

  // -------------------------------------------------------------------------
  // Undo/redo helpers
  // -------------------------------------------------------------------------

  String _currentSlotsJson() => PgSlot.encodeList(state.slots);
  String _currentRowsJson() => PgRow.encodeList(state.rows);

  // Returns the heightIn of the row that contains [subRow].
  double _rowHeightForSubRow(int subRow) {
    final rowIndex = subRow ~/ 4;
    if (rowIndex >= state.rows.length) return 24.0;
    return state.rows[rowIndex].heightIn;
  }

  // Compute spanQuarters for [nodeType] given [items] (or empty placeholder).
  int _computeSpan(String nodeType, List<SlotItem> items, double rowHeightIn) {
    if (nodeType == 'shelf') {
      if (items.isEmpty) return emptyShelfQuarters;
      final maxFolded = items
          .map((i) => foldedHeight(i.category))
          .reduce(math.max);
      final quarterIn = rowHeightIn / 4;
      return math.max(2, (maxFolded / quarterIn).ceil() + 1);
    }
    // shoulder / faceout / ubar: size to tallest item
    if (items.isEmpty) return 4;
    final maxHang = items.map((i) => hangLength(i.category)).reduce(math.max);
    return autoSpanQuarters(
        items.firstWhere((i) => hangLength(i.category) == maxHang).category,
        rowHeightIn);
  }

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
  // Fixture placement
  // -------------------------------------------------------------------------

  /// Place an empty fixture at [col] × [subRow] with the given [nodeType].
  /// No-op if a fixture already exists at that position.
  void placeFixture(int col, int subRow, String nodeType) {
    if (state.slots.any((s) => s.col == col && s.subRow == subRow)) return;
    final pg = state.planogram;
    if (pg == null) return;
    final id = 'slot_${col}_$subRow';
    final rowIndex = subRow ~/ 4;
    final newSlot = PgSlot(
      id: id,
      position: subRow * pg.cols + col + 1,
      row: rowIndex,
      col: col,
      nodeType: nodeType,
      subRow: subRow,
      spanQuarters: nodeType == 'shelf' ? emptyShelfQuarters : 4,
    );
    _record('Place fixture', () {
      state = state.copyWith(slots: [...state.slots, newSlot]);
    });
  }

  /// Remove the fixture at [col] × [subRow].
  void removeFixture(int col, int subRow) {
    _record('Remove fixture', () {
      state = state.copyWith(
        slots: state.slots
            .where((s) => !(s.col == col && s.subRow == subRow))
            .toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Item assignment
  // -------------------------------------------------------------------------

  static const _capacity = {'shoulder': 1, 'faceout': 6, 'ubar': 6, 'shelf': 99};

  /// Append [item] to the fixture at [col] × [subRow].
  /// Enforces type capacity. Auto-sizes [spanQuarters] after adding.
  void addItemToSlot(int col, int subRow, SlotItem item) {
    _record('Add item', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.col != col || s.subRow != subRow) return s;
          final cap = _capacity[s.nodeType] ?? 6;
          if (s.items.length >= cap) return s;
          final newItems = [...s.items, item];
          final rh = _rowHeightForSubRow(subRow);
          return s.copyWith(
            items: newItems,
            spanQuarters: _computeSpan(s.nodeType, newItems, rh),
          );
        }).toList(),
      );
    });
  }

  /// Remove the item at [itemIndex] from the fixture at [col] × [subRow].
  /// Auto-sizes [spanQuarters] after removal.
  void removeItemFromSlot(int col, int subRow, int itemIndex) {
    _record('Remove item', () {
      state = state.copyWith(
        slots: state.slots.map((s) {
          if (s.col != col || s.subRow != subRow) return s;
          final newItems = [...s.items]..removeAt(itemIndex);
          final rh = _rowHeightForSubRow(subRow);
          return s.copyWith(
            items: newItems,
            spanQuarters: _computeSpan(s.nodeType, newItems, rh),
          );
        }).toList(),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Row height
  // -------------------------------------------------------------------------

  /// Update the physical height of row [rowIndex] and re-size all fixtures
  /// whose subRow falls in that row.
  void setRowHeight(int rowIndex, double heightIn) {
    _record('Set row height', () {
      final newRows = state.rows.map((r) {
        if (r.index != rowIndex) return r;
        return r.copyWith(heightIn: heightIn);
      }).toList();
      // Re-compute spanQuarters for all fixtures in this row.
      final newSlots = state.slots.map((s) {
        if (s.subRow ~/ 4 != rowIndex) return s;
        return s.copyWith(
            spanQuarters: _computeSpan(s.nodeType, s.items, heightIn));
      }).toList();
      state = state.copyWith(rows: newRows, slots: newSlots);
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
