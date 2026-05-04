# Planogram Slot Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current single-product row-based planogram bay view with a fixture-first quarter-slot grid system where users place fixtures (shoulder, faceout, ubar, shelf) then press them to assign products; fixtures auto-size based on item hang/fold length.

**Architecture:** New pure-logic helpers (`slot_sizing.dart`), `SlotItem` class, extended `PgSlot`/`PgRow` models, five new notifier methods, completely rebuilt `_BayView` (extracted to `bay_view.dart`), new `FixturePickerSheet` and `ProductAssignmentSheet` widgets, rewritten `SlotCellWidget`. The `_GridView` (table type) is unchanged.

**Tech Stack:** Flutter/Dart, Riverpod 2.5+ (`@riverpod`), Firestore JSON blobs (`slotsJson`/`rowsJson`), flutter_test.

---

## File Map

| Action | File | Responsibility |
|---|---|---|
| Create | `lib/features/planogram/slot_item.dart` | `SlotItem` data class with JSON round-trip |
| Create | `lib/features/planogram/slot_sizing.dart` | Pure functions: `hangLength`, `autoSpanQuarters`, `foldedHeight`, `shelfSpanQuarters` |
| Modify | `lib/features/planogram/pg_row.dart` | Add `heightIn: double` (default 24.0) |
| Modify | `lib/features/planogram/planogram_slot.dart` | Add `nodeType`, `items`, `subRow`, `spanQuarters`; back-compat in `fromJson` |
| Modify | `lib/features/planogram/planogram_editor_provider.dart` | Add `placeFixture`, `removeFixture`, `addItemToSlot`, `removeItemFromSlot`, `setRowHeight` |
| Create | `lib/features/planogram/fixture_picker_sheet.dart` | Bottom sheet: 4 fixture type tiles; sets pending placement type |
| Create | `lib/features/planogram/product_assignment_sheet.dart` | Bottom sheet: assigned items, add/remove products, fit indicator |
| Modify | `lib/features/planogram/slot_cell_widget.dart` | Rewrite for 4 fixture types + empty fixture state + quarter-height |
| Create | `lib/features/planogram/bay_view.dart` | Seamless column-based grid (replaces `_BayView` in editor screen) |
| Modify | `lib/features/planogram/planogram_editor_screen.dart` | Wire `BayView`, FAB, placement mode; remove old `_BayView` |
| Create | `test/features/planogram/slot_sizing_test.dart` | Unit tests for all sizing helpers |
| Create | `test/features/planogram/slot_item_test.dart` | Unit tests for `SlotItem` JSON round-trip |
| Modify | `test/features/planogram/pg_slot_test.dart` | Tests for new fields + back-compat |
| Modify | `test/features/planogram/pg_row_test.dart` | Test for `heightIn` |

---

### Task 1: `SlotItem` + `slot_sizing.dart` pure helpers

**Files:**
- Create: `lib/features/planogram/slot_item.dart`
- Create: `lib/features/planogram/slot_sizing.dart`
- Create: `test/features/planogram/slot_sizing_test.dart`
- Create: `test/features/planogram/slot_item_test.dart`

- [ ] **Step 1: Write failing tests for `slot_sizing.dart`**

Create `test/features/planogram/slot_sizing_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/slot_sizing.dart';

void main() {
  group('hangLength', () {
    test('pants → 36"', () => expect(hangLength('pants'), 36));
    test('jeans → 36"', () => expect(hangLength('Jeans'), 36)); // case-insensitive
    test('dress → 48"', () => expect(hangLength('dress'), 48));
    test('coat → 48"', () => expect(hangLength('coat'), 48));
    test('jacket → 30"', () => expect(hangLength('jacket'), 30));
    test('hoodie → 30"', () => expect(hangLength('Hoodie'), 30));
    test('shirt → 30"', () => expect(hangLength('shirt'), 30));
    test('tee → 30"', () => expect(hangLength('tee'), 30));
    test('bra → 12"', () => expect(hangLength('bra'), 12));
    test('lingerie → 12"', () => expect(hangLength('lingerie'), 12));
    test('unknown → 18"', () => expect(hangLength('accessories'), 18));
  });

  group('foldedHeight', () {
    test('hoodie → 12"', () => expect(foldedHeight('hoodie'), 12));
    test('coat NOT in folded (falls to default 6")', () => expect(foldedHeight('coat'), 6));
    test('jacket → 10"', () => expect(foldedHeight('jacket'), 10));
    test('pants → 8"', () => expect(foldedHeight('pants'), 8));
    test('dress → 8"', () => expect(foldedHeight('dress'), 8));
    test('shirt → 6"', () => expect(foldedHeight('shirt'), 6));
    test('tee → 6"', () => expect(foldedHeight('tee'), 6));
    test('bra → 4"', () => expect(foldedHeight('bra'), 4));
    test('unknown → 6"', () => expect(foldedHeight('accessories'), 6));
  });

  group('autoSpanQuarters (rowHeight=24, quarterIn=6)', () {
    test('bra 12" → 2 quarters', () => expect(autoSpanQuarters('bra', 24.0), 2));
    test('shirt 30" → 5 quarters', () => expect(autoSpanQuarters('shirt', 24.0), 5));
    test('pants 36" → 6 quarters', () => expect(autoSpanQuarters('pants', 24.0), 6));
    test('dress 48" → 8 quarters', () => expect(autoSpanQuarters('dress', 24.0), 8));
    test('default 18" → 3 quarters', () => expect(autoSpanQuarters('accessories', 24.0), 3));
    test('minimum is 1', () => expect(autoSpanQuarters('bra', 100.0), 1));
  });

  group('shelfSpanQuarters (rowHeight=24, quarterIn=6, +1 clearance)', () {
    test('tee 6" → ceil(6/6)+1 = 2', () => expect(shelfSpanQuarters('tee', 24.0), 2));
    test('hoodie 12" → ceil(12/6)+1 = 3', () => expect(shelfSpanQuarters('hoodie', 24.0), 3));
    test('jacket 10" → ceil(10/6)+1 = 3', () => expect(shelfSpanQuarters('jacket', 24.0), 3));
    test('pants 8" → ceil(8/6)+1 = 3', () => expect(shelfSpanQuarters('pants', 24.0), 3));
    test('bra 4" → ceil(4/6)+1 = 2', () => expect(shelfSpanQuarters('bra', 24.0), 2));
    test('empty shelf → 2', () => expect(emptyShelfQuarters, 2));
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```
flutter test test/features/planogram/slot_sizing_test.dart
```
Expected: FAIL with "Target of URI doesn't exist"

- [ ] **Step 3: Create `lib/features/planogram/slot_item.dart`**

```dart
import 'dart:convert';

/// A product assigned to a fixture slot. Stored inline in PgSlot.items.
class SlotItem {
  final String productId;
  final String productName;
  final String productSku;
  final String category; // Product.category — used for auto-sizing
  final String? colorHex;

  const SlotItem({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.category,
    this.colorHex,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'productSku': productSku,
        'category': category,
        if (colorHex != null) 'colorHex': colorHex,
      };

  factory SlotItem.fromJson(Map<String, dynamic> json) => SlotItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        productSku: json['productSku'] as String,
        category: json['category'] as String? ?? 'other',
        colorHex: json['colorHex'] as String?,
      );

  static String encodeList(List<SlotItem> items) =>
      jsonEncode(items.map((i) => i.toJson()).toList());

  static List<SlotItem> decodeList(String json) {
    if (json.isEmpty || json == '[]') return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => SlotItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
```

- [ ] **Step 4: Create `lib/features/planogram/slot_sizing.dart`**

```dart
import 'dart:math' as math;

// Empty shelf minimum: 1 quarter for item + 1 clearance quarter.
const int emptyShelfQuarters = 2;

/// Hang length in inches by product category (case-insensitive keyword match).
int hangLength(String category) {
  final c = category.toLowerCase();
  if (_any(c, ['pants', 'jeans', 'trousers', 'shorts'])) return 36;
  if (_any(c, ['dress', 'coat', 'gown'])) return 48;
  if (_any(c, ['jacket', 'blazer', 'hoodie', 'sweater'])) return 30;
  if (_any(c, ['shirt', 'blouse', 'top', 'tee', 'tank'])) return 30;
  if (_any(c, ['bra', 'bralette', 'underwear', 'lingerie'])) return 12;
  return 18;
}

/// Folded height in inches for shelf items (coat is hanging-only, not here).
int foldedHeight(String category) {
  final c = category.toLowerCase();
  if (_any(c, ['hoodie', 'sweater', 'gown'])) return 12;
  if (_any(c, ['jacket', 'blazer'])) return 10;
  if (_any(c, ['pants', 'jeans', 'trousers', 'dress'])) return 8;
  if (_any(c, ['shirt', 'blouse', 'top', 'tee', 'tank', 'shorts'])) return 6;
  if (_any(c, ['bra', 'bralette', 'underwear', 'lingerie'])) return 4;
  return 6;
}

bool _any(String c, List<String> kw) => kw.any(c.contains);

/// Quarter-slots needed for a hanging fixture (shoulder/faceout/ubar).
/// Minimum 1. rowHeightIn defaults to 24.0 if omitted.
int autoSpanQuarters(String category, [double rowHeightIn = 24.0]) {
  final needed = hangLength(category);
  final quarterIn = rowHeightIn / 4;
  return math.max(1, (needed / quarterIn).ceil());
}

/// Quarter-slots for a shelf with item (folded height + 1 clearance quarter).
/// Minimum 2 (even for the thinnest item).
int shelfSpanQuarters(String category, [double rowHeightIn = 24.0]) {
  final folded = foldedHeight(category);
  final quarterIn = rowHeightIn / 4;
  return math.max(2, (folded / quarterIn).ceil() + 1);
}
```

- [ ] **Step 5: Run tests — expect PASS**

```
flutter test test/features/planogram/slot_sizing_test.dart
```
Expected: All 20 tests PASS.

- [ ] **Step 6: Write failing tests for `SlotItem`**

Create `test/features/planogram/slot_item_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/planogram/slot_item.dart';

void main() {
  group('SlotItem JSON round-trip', () {
    test('all fields survive toJson/fromJson', () {
      const item = SlotItem(
        productId: 'p1',
        productName: 'Classic Tee',
        productSku: 'TS-001',
        category: 'tee',
        colorHex: '#A8472B',
      );
      final json = item.toJson();
      final restored = SlotItem.fromJson(json);
      expect(restored.productId, 'p1');
      expect(restored.productName, 'Classic Tee');
      expect(restored.category, 'tee');
      expect(restored.colorHex, '#A8472B');
    });

    test('missing category defaults to "other"', () {
      final json = <String, dynamic>{
        'productId': 'p2',
        'productName': 'Mystery',
        'productSku': 'X-001',
      };
      final item = SlotItem.fromJson(json);
      expect(item.category, 'other');
    });

    test('null colorHex omitted from toJson', () {
      const item = SlotItem(
          productId: 'p3', productName: 'N', productSku: 'N-1', category: 'shirt');
      expect(item.toJson().containsKey('colorHex'), isFalse);
    });
  });
}
```

- [ ] **Step 7: Run tests — expect PASS**

```
flutter test test/features/planogram/slot_item_test.dart
```
Expected: All 3 tests PASS.

- [ ] **Step 8: Commit**

```
git add lib/features/planogram/slot_item.dart lib/features/planogram/slot_sizing.dart test/features/planogram/slot_sizing_test.dart test/features/planogram/slot_item_test.dart
git commit -m "feat: SlotItem model + slot_sizing pure helpers (hang/fold/quarter math)"
```

---

### Task 2: `PgRow` — add `heightIn`

**Files:**
- Modify: `lib/features/planogram/pg_row.dart`
- Modify: `test/features/planogram/pg_row_test.dart`

- [ ] **Step 1: Write failing test**

Open `test/features/planogram/pg_row_test.dart` and add to the existing `main()`:

```dart
group('PgRow.heightIn', () {
  test('defaults to 24.0 when absent from JSON', () {
    final row = PgRow.fromJson({'index': 0, 'rowType': 'bar'});
    expect(row.heightIn, 24.0);
  });

  test('survives JSON round-trip', () {
    final row = PgRow(index: 1, rowType: 'shelf', heightIn: 36.0);
    final restored = PgRow.fromJson(row.toJson());
    expect(restored.heightIn, 36.0);
  });

  test('copyWith updates heightIn', () {
    const row = PgRow(index: 0);
    expect(row.copyWith(heightIn: 30.0).heightIn, 30.0);
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

```
flutter test test/features/planogram/pg_row_test.dart
```
Expected: FAIL with "The getter 'heightIn' isn't defined"

- [ ] **Step 3: Update `lib/features/planogram/pg_row.dart`**

```dart
import 'dart:convert';

class PgRow {
  final int index;
  final String rowType; // 'bar' | 'shelf'
  final String? label;
  final double heightIn; // Physical height in inches. Default: 24.0.

  const PgRow({
    required this.index,
    this.rowType = 'bar',
    this.label,
    this.heightIn = 24.0,
  });

  PgRow copyWith({String? rowType, String? label, double? heightIn}) => PgRow(
        index: index,
        rowType: rowType ?? this.rowType,
        label: label ?? this.label,
        heightIn: heightIn ?? this.heightIn,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'rowType': rowType,
        if (label != null) 'label': label,
        'heightIn': heightIn,
      };

  factory PgRow.fromJson(Map<String, dynamic> json) => PgRow(
        index: json['index'] as int,
        rowType: json['rowType'] as String? ?? 'bar',
        label: json['label'] as String?,
        heightIn: (json['heightIn'] as num?)?.toDouble() ?? 24.0,
      );

  static String encodeList(List<PgRow> rows) =>
      jsonEncode(rows.map((r) => r.toJson()).toList());

  static List<PgRow> decodeList(String json) {
    if (json.isEmpty || json == '[]') return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PgRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<PgRow> defaults(int count, String planogramType) =>
      List.generate(
        count,
        (i) => PgRow(
          index: i,
          rowType: planogramType == 'table' ? 'shelf' : 'bar',
        ),
      );
}
```

- [ ] **Step 4: Run — expect PASS**

```
flutter test test/features/planogram/pg_row_test.dart
```
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```
git add lib/features/planogram/pg_row.dart test/features/planogram/pg_row_test.dart
git commit -m "feat: PgRow.heightIn (default 24\", quarter math uses this)"
```

---

### Task 3: `PgSlot` — new fields + back-compat

**Files:**
- Modify: `lib/features/planogram/planogram_slot.dart`
- Modify: `test/features/planogram/pg_slot_test.dart`

- [ ] **Step 1: Write failing tests**

Add to `test/features/planogram/pg_slot_test.dart`:

```dart
group('PgSlot new fields', () {
  test('new fields survive round-trip', () {
    final slot = PgSlot(
      id: 'slot_1_0',
      position: 1,
      col: 1,
      nodeType: 'faceout',
      items: [
        SlotItem(
            productId: 'p1',
            productName: 'Shirt A',
            productSku: 'SA-001',
            category: 'shirt',
            colorHex: '#BF5534'),
      ],
      subRow: 4,
      spanQuarters: 5,
    );
    final restored = PgSlot.fromJson(slot.toJson());
    expect(restored.nodeType, 'faceout');
    expect(restored.items.length, 1);
    expect(restored.items.first.productSku, 'SA-001');
    expect(restored.items.first.category, 'shirt');
    expect(restored.subRow, 4);
    expect(restored.spanQuarters, 5);
  });

  test('back-compat: legacy productId wrapped into items', () {
    final oldJson = <String, dynamic>{
      'id': 'slot_0_2',
      'position': 3,
      'row': 0,
      'col': 2,
      'productId': 'p99',
      'productName': 'Old Jacket',
      'productSku': 'OJ-001',
      'spanRows': 2,
    };
    final slot = PgSlot.fromJson(oldJson);
    expect(slot.items.length, 1);
    expect(slot.items.first.productId, 'p99');
    expect(slot.items.first.productName, 'Old Jacket');
    expect(slot.items.first.category, 'other'); // no category in old data
    expect(slot.subRow, 0); // row 0 → subRow 0
    expect(slot.spanQuarters, 8); // spanRows 2 → 8 quarters
    expect(slot.nodeType, 'shoulder'); // default
  });

  test('back-compat: no items and no productId → empty items list', () {
    final json = <String, dynamic>{'id': 's1', 'position': 1, 'row': 0, 'col': 0};
    final slot = PgSlot.fromJson(json);
    expect(slot.items, isEmpty);
    expect(slot.nodeType, 'shoulder');
  });

  test('cleared() removes items and resets spanQuarters to 4', () {
    final slot = PgSlot(
      id: 's1',
      position: 1,
      col: 0,
      nodeType: 'faceout',
      items: [SlotItem(productId: 'p1', productName: 'X', productSku: 'X', category: 'shirt')],
      subRow: 0,
      spanQuarters: 5,
    );
    final cleared = slot.cleared();
    expect(cleared.items, isEmpty);
    expect(cleared.spanQuarters, 4);
    expect(cleared.nodeType, 'faceout'); // type preserved
  });
});
```

Add import at top of test file:
```dart
import 'package:merch_mobile/features/planogram/slot_item.dart';
```

- [ ] **Step 2: Run — expect FAIL**

```
flutter test test/features/planogram/pg_slot_test.dart
```
Expected: FAIL with "The getter 'nodeType' isn't defined"

- [ ] **Step 3: Rewrite `lib/features/planogram/planogram_slot.dart`**

```dart
import 'dart:convert';

import 'slot_item.dart';

/// A fixture slot in a planogram grid. Stored as JSON in [Planogram.slotsJson].
///
/// Back-compat: old data with top-level productId/productName/productSku is
/// synthesised into a one-item [items] list on deserialise. Missing [subRow]
/// is derived from row*4; missing [spanQuarters] from spanRows*4.
class PgSlot {
  final String id;
  final int position;
  final int row;        // 0-indexed row (kept for back-compat / _GridView)
  final int col;        // 0-indexed column

  // New fixture fields
  final String nodeType;       // 'shoulder' | 'faceout' | 'ubar' | 'shelf'
  final List<SlotItem> items;  // products assigned to this fixture
  final int subRow;            // quarter-slot index from top (authoritative)
  final int spanQuarters;      // quarter-slots tall

  // Legacy fields (kept so _GridView continues to compile unchanged)
  final String? productId;
  final String? productName;
  final String? productSku;
  final String presentationMode; // 'face_out' | 'shoulder_out' | 'folded'
  final int spanCols;
  final int spanRows;
  final int rotation;
  final String? colorHex;
  final String? sectionLabel;

  const PgSlot({
    required this.id,
    required this.position,
    this.row = 0,
    this.col = 0,
    this.nodeType = 'shoulder',
    this.items = const [],
    this.subRow = 0,
    this.spanQuarters = 4,
    this.productId,
    this.productName,
    this.productSku,
    this.presentationMode = 'face_out',
    this.spanCols = 1,
    this.spanRows = 1,
    this.rotation = 0,
    this.colorHex,
    this.sectionLabel,
  });

  PgSlot copyWith({
    String? nodeType,
    List<SlotItem>? items,
    int? subRow,
    int? spanQuarters,
    String? productId,
    String? productName,
    String? productSku,
    String? presentationMode,
    int? spanCols,
    int? spanRows,
    int? rotation,
    String? colorHex,
    String? sectionLabel,
  }) =>
      PgSlot(
        id: id,
        position: position,
        row: row,
        col: col,
        nodeType: nodeType ?? this.nodeType,
        items: items ?? this.items,
        subRow: subRow ?? this.subRow,
        spanQuarters: spanQuarters ?? this.spanQuarters,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        productSku: productSku ?? this.productSku,
        presentationMode: presentationMode ?? this.presentationMode,
        spanCols: spanCols ?? this.spanCols,
        spanRows: spanRows ?? this.spanRows,
        rotation: rotation ?? this.rotation,
        colorHex: colorHex ?? this.colorHex,
        sectionLabel: sectionLabel ?? this.sectionLabel,
      );

  /// Return a cleared slot: items removed, spanQuarters reset to 4 (1 row).
  PgSlot cleared() => PgSlot(
        id: id,
        position: position,
        row: row,
        col: col,
        nodeType: nodeType,
        subRow: subRow,
        spanQuarters: 4,
        presentationMode: presentationMode,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'row': row,
        'col': col,
        'nodeType': nodeType,
        'items': items.map((i) => i.toJson()).toList(),
        'subRow': subRow,
        'spanQuarters': spanQuarters,
        if (productId != null) 'productId': productId,
        if (productName != null) 'productName': productName,
        if (productSku != null) 'productSku': productSku,
        'presentationMode': presentationMode,
        'spanCols': spanCols,
        'spanRows': spanRows,
        'rotation': rotation,
        if (colorHex != null) 'colorHex': colorHex,
        if (sectionLabel != null) 'sectionLabel': sectionLabel,
      };

  factory PgSlot.fromJson(Map<String, dynamic> json) {
    final row = (json['row'] as num?)?.toInt() ?? 0;
    final spanRows = (json['spanRows'] as num?)?.toInt() ?? 1;

    // Synthesise items from legacy top-level product fields if needed.
    List<SlotItem> items;
    if (json.containsKey('items') && json['items'] != null) {
      final raw = json['items'] as List;
      items = raw
          .map((e) => SlotItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (json['productId'] != null) {
      items = [
        SlotItem(
          productId: json['productId'] as String,
          productName: json['productName'] as String? ?? '',
          productSku: json['productSku'] as String? ?? '',
          category: 'other', // legacy data has no category
          colorHex: json['colorHex'] as String?,
        ),
      ];
    } else {
      items = [];
    }

    return PgSlot(
      id: json['id'] as String,
      position: (json['position'] ?? json['sequence'] ?? 1) as int,
      row: row,
      col: (json['col'] as num?)?.toInt() ??
          (((json['position'] ?? json['sequence'] ?? 1) as int) - 1),
      nodeType: json['nodeType'] as String? ?? 'shoulder',
      items: items,
      subRow: (json['subRow'] as num?)?.toInt() ?? (row * 4),
      spanQuarters: (json['spanQuarters'] as num?)?.toInt() ?? (spanRows * 4),
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productSku: json['productSku'] as String?,
      presentationMode: json['presentationMode'] as String? ?? 'face_out',
      spanCols: (json['spanCols'] as num?)?.toInt() ?? 1,
      spanRows: spanRows,
      rotation: (json['rotation'] as num?)?.toInt() ?? 0,
      colorHex: json['colorHex'] as String?,
      sectionLabel: json['sectionLabel'] as String?,
    );
  }

  static String encodeList(List<PgSlot> slots) =>
      jsonEncode(slots.map((s) => s.toJson()).toList());

  static List<PgSlot> decodeList(String json) {
    if (json.isEmpty || json == '[]') return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PgSlot.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<PgSlot> defaults(int count) => List.generate(
        count,
        (i) => PgSlot(id: 'slot_${i + 1}', position: i + 1, col: i),
      );

  static List<PgSlot> defaultGrid(int rows, int cols, String planogramType) {
    final defaultMode = planogramType == 'table' ? 'folded' : 'face_out';
    final slots = <PgSlot>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        slots.add(PgSlot(
          id: 'slot_${r}_$c',
          position: r * cols + c + 1,
          row: r,
          col: c,
          subRow: r * 4,
          presentationMode: defaultMode,
        ));
      }
    }
    return slots;
  }

  static String defaultMode(String planogramType) {
    switch (planogramType) {
      case 'wall':  return 'face_out';
      case 'rack':  return 'shoulder_out';
      case 'shelf': return 'shoulder_out';
      case 'table': return 'folded';
      default:      return 'face_out';
    }
  }
}
```

- [ ] **Step 4: Run — expect PASS**

```
flutter test test/features/planogram/pg_slot_test.dart
```
Expected: All tests PASS (including old ones).

- [ ] **Step 5: Commit**

```
git add lib/features/planogram/planogram_slot.dart test/features/planogram/pg_slot_test.dart
git commit -m "feat: PgSlot nodeType/items/subRow/spanQuarters + back-compat fromJson"
```

---

### Task 4: `PlanogramEditorNotifier` — new methods

**Files:**
- Modify: `lib/features/planogram/planogram_editor_provider.dart`

- [ ] **Step 1: Add imports at top of `planogram_editor_provider.dart`**

Add after existing imports:
```dart
import 'dart:math' as math;
import 'slot_item.dart';
import 'slot_sizing.dart';
```

- [ ] **Step 2: Add private sizing helper inside the notifier class**

Add after the `_currentRowsJson` method:

```dart
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
```

- [ ] **Step 3: Add `placeFixture` and `removeFixture`**

Add inside the notifier class after `setRowType`:

```dart
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
```

- [ ] **Step 4: Add `addItemToSlot` and `removeItemFromSlot`**

```dart
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
```

- [ ] **Step 5: Add `setRowHeight`**

```dart
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
```

- [ ] **Step 6: Run full test suite**

```
flutter test
```
Expected: All existing tests PASS (new provider methods are additive — no tests needed beyond integration coverage provided by later tasks).

- [ ] **Step 7: Commit**

```
git add lib/features/planogram/planogram_editor_provider.dart
git commit -m "feat: PlanogramEditorNotifier — placeFixture, addItemToSlot, removeItemFromSlot, setRowHeight"
```

---

### Task 5: `FixturePickerSheet`

**Files:**
- Create: `lib/features/planogram/fixture_picker_sheet.dart`

- [ ] **Step 1: Create the widget**

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

/// Bottom sheet that lets the user choose a fixture type to place.
/// Calls [onPick] with the chosen nodeType string, then dismisses.
class FixturePickerSheet extends StatelessWidget {
  const FixturePickerSheet({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  static const _fixtures = [
    (nodeType: 'shoulder', label: 'Shoulder', icon: Icons.hook, color: Color(0xFF3A3735)),
    (nodeType: 'faceout',  label: 'Face-out', icon: Icons.view_agenda_outlined, color: Color(0xFF2E6DA4)),
    (nodeType: 'ubar',     label: 'U-Bar',    icon: Icons.horizontal_rule,  color: Color(0xFFBF5534)),
    (nodeType: 'shelf',    label: 'Shelf',    icon: Icons.table_rows_outlined, color: Color(0xFF6B6660)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spaceMd, DesignTokens.spaceMd, DesignTokens.spaceMd, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'ADD FIXTURE',
            style: TextStyle(
              fontSize: DesignTokens.typeSm,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: _fixtures.map((f) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _FixtureTile(
                    label: f.label,
                    icon: f.icon,
                    color: f.color,
                    onTap: () {
                      Navigator.pop(context);
                      onPick(f.nodeType);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.canvasBg,
          border: Border.all(color: const Color(0xFFD5D2CB)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```
flutter analyze lib/features/planogram/fixture_picker_sheet.dart
```
Expected: No issues.

- [ ] **Step 3: Commit**

```
git add lib/features/planogram/fixture_picker_sheet.dart
git commit -m "feat: FixturePickerSheet — FAB bottom sheet with 4 fixture type tiles"
```

---

### Task 6: `ProductAssignmentSheet`

**Files:**
- Create: `lib/features/planogram/product_assignment_sheet.dart`

- [ ] **Step 1: Create the widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';
import 'slot_item.dart';
import 'slot_sizing.dart';

/// Bottom sheet shown when the user presses a placed fixture.
/// Displays assigned products, allows add/remove, shows fit indicator.
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
    // Watch so the sheet updates when items change.
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
        ? editorState.rows[(currentSlot.subRow ~/ 4).clamp(0, editorState.rows.length - 1)].heightIn
        : 24.0;

    // Fit indicator
    String fitLabel = '';
    bool fitOk = true;
    if (currentSlot.items.isNotEmpty && currentSlot.nodeType != 'shelf') {
      final maxHang = currentSlot.items
          .map((i) => hangLength(i.category))
          .reduce((a, b) => a > b ? a : b);
      final available = (editorState.rows.length - currentSlot.subRow ~/ 4) * rowHeight;
      fitOk = available >= maxHang;
      fitLabel = fitOk
          ? '✓ Fits (${maxHang}" in ${available.toInt()}" available)'
          : '✗ Won\'t fully fit (${maxHang}" needed, ${available.toInt()}" available)';
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
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _typeLabel[currentSlot.nodeType] ?? currentSlot.nodeType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
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
                        fontWeight: DesignTokens.weightBold,
                        color: AppTheme.textSecondary,
                      ),
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
            // Product list
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
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
                                      fontWeight: DesignTokens.weightMedium,
                                    )),
                                Text('${item.productSku} · ${hangLength(item.category)}"',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.textSecondary,
                                    )),
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
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFD5D2CB),
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: AppTheme.accent),
                            SizedBox(width: 6),
                            Text('Add product',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: DesignTokens.weightBold,
                                  color: AppTheme.accent,
                                )),
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
                          fontWeight: DesignTokens.weightBold,
                          color: fitOk
                              ? const Color(0xFF2E7D32)
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spaceMd),
                  TextButton(
                    onPressed: () {
                      notifier.removeFixture(currentSlot.col, currentSlot.subRow);
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'REMOVE FIXTURE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
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

  void _openPicker(
      BuildContext ctx, PlanogramEditorNotifier notifier, PgSlot currentSlot) {
    ProductSlotPicker.show(
      ctx,
      planogramId: planogramId,
      onAssign: (productId, name, sku, {colorHex}) {
        // Product model's category is not passed by the picker signature — we
        // use 'other' as fallback until the picker is extended in a future task.
        // The user will see correct sizing once product catalogue exposes category.
        notifier.addItemToSlot(
          currentSlot.col,
          currentSlot.subRow,
          SlotItem(
            productId: productId,
            productName: name,
            productSku: sku,
            category: 'other',
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
```

> **Note on category:** `ProductSlotPicker.show` currently delivers only `productId`, `name`, `sku`, `colorHex` — not `category`. For this task use `'other'` as a placeholder. Task 7 extends the picker signature to pass `category` so sizing works correctly.

- [ ] **Step 2: Extend `ProductSlotPicker.show` to pass category**

In `lib/features/planogram/product_slot_picker.dart`, update the `SlotAssignCallback` typedef and the `_assign` method:

```dart
// Change typedef to include category
typedef SlotAssignCallback = void Function(
  String productId,
  String name,
  String sku,
  String category, {
  String? colorHex,
});
```

Update `_assign`:
```dart
  Future<void> _assign(Product product) async {
    if (widget.onAssign != null) {
      widget.onAssign!(product.id, product.name, product.sku, product.category);
      if (mounted) Navigator.pop(context);
      return;
    }
    // Legacy path unchanged
    final editor = ref.read(
        planogramEditorProvider(widget.planogramId!).notifier);
    editor.assignProduct(
        widget.slotId!, product.id, product.name, product.sku);
    await editor.save(widget.planogramId!);
    if (mounted) Navigator.pop(context);
  }
```

Update `ProductAssignmentSheet._openPicker` to use the category:
```dart
  void _openPicker(BuildContext ctx, PlanogramEditorNotifier notifier, PgSlot currentSlot) {
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
```

Also update the one call to `ProductSlotPicker.show` in `planogram_editor_screen.dart` `_openPicker` (it calls with the old signature):
```dart
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
```

- [ ] **Step 3: Analyze**

```
flutter analyze lib/features/planogram/
```
Expected: No issues.

- [ ] **Step 4: Commit**

```
git add lib/features/planogram/product_assignment_sheet.dart lib/features/planogram/product_slot_picker.dart lib/features/planogram/planogram_editor_screen.dart
git commit -m "feat: ProductAssignmentSheet + extend picker to pass product category"
```

---

### Task 7: Rewrite `SlotCellWidget`

**Files:**
- Modify: `lib/features/planogram/slot_cell_widget.dart`

The new widget is quarter-height-based, shows 4 fixture type renderings + empty fixture state, and no longer has span drag handles (those are in `_GridView` only — out of scope for `_BayView`).

- [ ] **Step 1: Replace `lib/features/planogram/slot_cell_widget.dart`**

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_slot.dart';

/// Renders a single fixture cell in the bay view.
///
/// Height = [quarterHeight] × [slot.spanQuarters] + gap adjustments.
/// [isActive] highlights the cell with an accent border.
/// [onPress] is called when the user taps the cell (opens product sheet).
class SlotCellWidget extends StatelessWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.cellWidth,
    required this.quarterHeight,
    this.isActive = false,
    this.onPress,
  });

  final PgSlot slot;
  final double cellWidth;
  final double quarterHeight;
  final bool isActive;
  final VoidCallback? onPress;

  // Type stripe colours
  static const _stripeColor = {
    'shoulder': Color(0x38393735),
    'faceout': Color(0xFF2E6DA4),
    'ubar': AppTheme.accent,
    'shelf': Color(0xFF6B6660),
  };
  static const _pillBg = {
    'shoulder': Color(0x103A3735),
    'faceout': Color(0x1A2E6DA4),
    'ubar': Color(0x1ABF5534),
    'shelf': Color(0x1A6B6660),
  };
  static const _pillFg = {
    'shoulder': AppTheme.textSecondary,
    'faceout': Color(0xFF2E6DA4),
    'ubar': AppTheme.accent,
    'shelf': Color(0xFF6B6660),
  };
  static const _pillLabel = {
    'shoulder': 'SHOULDER',
    'faceout': 'FACE-OUT',
    'ubar': 'U-BAR',
    'shelf': 'SHELF',
  };

  @override
  Widget build(BuildContext context) {
    final h = quarterHeight * slot.spanQuarters +
        (slot.spanQuarters - 1) * 2.0; // 2px gap per quarter
    final w = cellWidth * slot.spanCols + (slot.spanCols - 1) * 4.0;

    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.canvasBg,
            border: Border.all(
              color: isActive ? AppTheme.accent : const Color(0x21393735),
              width: isActive ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type stripe
              Container(
                height: 2,
                color: _stripeColor[slot.nodeType] ?? AppTheme.primary,
              ),
              // Content
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: slot.items.isEmpty
                          ? _EmptyFixtureContent(nodeType: slot.nodeType)
                          : _buildFilledContent(h),
                    ),
                    // Type pill — top right
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: _pillBg[slot.nodeType],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _pillLabel[slot.nodeType] ?? slot.nodeType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 5.5,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: 0.5,
                            color: _pillFg[slot.nodeType] ?? AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    // Volume badge — bottom right (only when filled)
                    if (slot.items.isNotEmpty)
                      Positioned(
                        bottom: 2,
                        right: 4,
                        child: Text(
                          '2 CU FT',
                          style: const TextStyle(
                            fontSize: 5.5,
                            fontWeight: DesignTokens.weightBold,
                            color: Color(0x38393735),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Shelf plank at bottom
              if (slot.nodeType == 'shelf')
                Container(height: 3, color: const Color(0x886B6660)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledContent(double cellH) {
    switch (slot.nodeType) {
      case 'shoulder':
        return _ShoulderContent(slot: slot);
      case 'faceout':
        return _FaceoutContent(slot: slot);
      case 'ubar':
        return _UbarContent(slot: slot);
      case 'shelf':
        return _ShelfContent(slot: slot);
      default:
        return _ShoulderContent(slot: slot);
    }
  }
}

// ---------------------------------------------------------------------------
// Empty fixture placeholder
// ---------------------------------------------------------------------------
class _EmptyFixtureContent extends StatelessWidget {
  const _EmptyFixtureContent({required this.nodeType});
  final String nodeType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          nodeType == 'shelf'
              ? Icons.table_rows_outlined
              : nodeType == 'ubar'
                  ? Icons.horizontal_rule
                  : Icons.hook,
          size: 16,
          color: const Color(0x55393735),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x33393735)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            '+ ADD',
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w700,
              color: Color(0x88393735),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shoulder: single product icon + name + mode
// ---------------------------------------------------------------------------
class _ShoulderContent extends StatelessWidget {
  const _ShoulderContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    final item = slot.items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👕', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          item.productName,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'SHOULDER',
          style: const TextStyle(
            fontSize: 6,
            color: AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Face-out: N products header + colour-dot chips
// ---------------------------------------------------------------------------
class _FaceoutContent extends StatelessWidget {
  const _FaceoutContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${slot.items.length} product${slot.items.length == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 6.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 3),
        ...slot.items.take(5).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _hexColor(item.colorHex) ?? Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color? _hexColor(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// U-bar: cross-rod illustration + hanger + product chips
// ---------------------------------------------------------------------------
class _UbarContent extends StatelessWidget {
  const _UbarContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cross-rod
        Row(
          children: [
            Container(width: 5, height: 5,
                decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
            Expanded(child: Container(height: 2,
                decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1)))),
            Container(width: 5, height: 5,
                decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
          ],
        ),
        const SizedBox(height: 4),
        ...slot.items.take(4).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                      width: 2, height: 10,
                      decoration: BoxDecoration(
                          color: const Color(0x66393735),
                          borderRadius: BorderRadius.circular(1))),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0x0D393735),
                          borderRadius: BorderRadius.circular(2)),
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                            fontSize: 7, fontWeight: FontWeight.w700,
                            color: AppTheme.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shelf: icon + name (plank rendered by SlotCellWidget)
// ---------------------------------------------------------------------------
class _ShelfContent extends StatelessWidget {
  const _ShelfContent({required this.slot});
  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    final item = slot.items.first;
    return Row(
      children: [
        const Text('📦', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            item.productName,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed border painter (kept for _GridView empty cells)
// ---------------------------------------------------------------------------
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(
            metric.extractPath(dist, (dist + dash).clamp(0.0, metric.length)),
            paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
```

- [ ] **Step 2: Fix the `_DashedBorderPainter` reference in the old `_GridView`**

In `planogram_editor_screen.dart`, the `_GridView` had `_DashedBorderPainter`. Update its import and usage to use `DashedBorderPainter` (now exported from `slot_cell_widget.dart`). Find the `_DashedBorderPainter` class at the bottom of `planogram_editor_screen.dart` and **delete it** — it's now `DashedBorderPainter` in `slot_cell_widget.dart`.

Also update the one usage inside `_GridView`'s `SlotCellWidget` call — the existing `_buildCellContent` method in old `SlotCellWidget` used `_DashedBorderPainter`. Since `SlotCellWidget` is now rewritten, this is no longer needed in that file. The `_GridView` still uses the old `SlotCellWidget` interface — see Task 8 for how `_GridView` is preserved.

- [ ] **Step 3: Analyze**

```
flutter analyze lib/features/planogram/slot_cell_widget.dart
```
Expected: No issues.

- [ ] **Step 4: Commit**

```
git add lib/features/planogram/slot_cell_widget.dart
git commit -m "feat: SlotCellWidget rewrite — shoulder/faceout/ubar/shelf types, quarter-height sizing"
```

---

### Task 8: `BayView` + wire up `PlanogramEditorScreen`

**Files:**
- Create: `lib/features/planogram/bay_view.dart`
- Modify: `lib/features/planogram/planogram_editor_screen.dart`

- [ ] **Step 1: Create `lib/features/planogram/bay_view.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'fixture_picker_sheet.dart';
import 'planogram_editor_provider.dart';
import 'planogram_slot.dart';
import 'product_assignment_sheet.dart';
import 'slot_cell_widget.dart';

/// Seamless column-based planogram bay for wall/shelf/rack planogram types.
///
/// Layout: each column is stacked vertically. A row = 4 quarter-slots.
/// Fixtures are placed freely at any quarter position within a column.
/// No row headers or dividers — the wall flows continuously.
class BayView extends ConsumerStatefulWidget {
  const BayView({super.key, required this.planogramId});
  final String planogramId;

  @override
  ConsumerState<BayView> createState() => _BayViewState();
}

class _BayViewState extends ConsumerState<BayView> {
  static const double _cellWidth = 80.0;
  static const double _quarterHeight = 20.0; // px per quarter-slot
  static const double _gap = 2.0; // gap between stacked cells

  // When non-null: user picked a fixture type from the sheet and must now
  // tap an empty quarter in the grid to place it.
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
    setState(() => _pendingNodeType = null); // cancel any pending placement
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
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
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
                    child: _buildColumn(col, slots, totalQuarters,
                        isPendingPlacement),
                  ),
                );
              }),
            ),
          ),
        ),
        // Placement-mode banner
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
        // FAB
        Positioned(
          right: DesignTokens.spaceMd,
          bottom: DesignTokens.spaceMd,
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
      // Fill gap with empty quarter cells before this slot
      while (current < slot.subRow) {
        widgets.add(_emptyQuarterCell(col, current, isPendingPlacement));
        current++;
      }
      // Render fixture cell
      widgets.add(SlotCellWidget(
        slot: slot,
        cellWidth: _cellWidth,
        quarterHeight: _quarterHeight,
        onPress: () => _onFixturePress(slot),
      ));
      current += slot.spanQuarters;
    }

    // Fill remaining quarters at the bottom
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
      onTap: isPendingPlacement ? () => _onEmptyQuarterTap(col, subRow) : null,
      child: Container(
        width: _cellWidth,
        height: _quarterHeight,
        decoration: BoxDecoration(
          color: isPendingPlacement
              ? AppTheme.accent.withOpacity(0.07)
              : Colors.transparent,
          border: Border.all(
            color: isPendingPlacement
                ? AppTheme.accent.withOpacity(0.35)
                : const Color(0x22393735),
            style: BorderStyle.solid,
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
```

- [ ] **Step 2: Update `planogram_editor_screen.dart`**

Replace the `_BayView` class (lines 234–430 in the original file) with a call to `BayView`, and add the import. The `_GridView` class remains unchanged.

At the top of `planogram_editor_screen.dart`, add:
```dart
import 'bay_view.dart';
```

Replace the `_BayView(...)` constructor call in `_PlanogramEditorScreenState.build` with:
```dart
: BayView(planogramId: widget.planogramId),
```

Remove the entire `_BayView` class definition (lines 234–430).

Remove the `onTapEmpty`, `onTapFilled`, `onLongPress`, `onRowTypeToggle`, `onSpanCols`, `onSpanRows`, `onRotate` callbacks from the `_PlanogramEditorScreenState` — they are no longer passed to `BayView` (it manages its own interactions).

The `_openPicker`, `_activateSlot`, `_deactivate`, `_showActionSheet` methods are only used by `_GridView` now. Keep them for `_GridView` usage (table type planograms).

Final `build` method body for the non-table branch:
```dart
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
            .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
            .setSpanCols(row, col, v),
        onSpanRows: (row, col, v) => ref
            .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
            .setSpanRows(row, col, v),
        onRotate: (row, col) => ref
            .read(planogramEditorNotifierProvider(widget.planogramId).notifier)
            .cycleRotation(row, col),
      )
    : BayView(planogramId: widget.planogramId),
```

- [ ] **Step 3: Analyze the full planogram feature directory**

```
flutter analyze lib/features/planogram/
```
Expected: No issues.

- [ ] **Step 4: Run all tests**

```
flutter test
```
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```
git add lib/features/planogram/bay_view.dart lib/features/planogram/planogram_editor_screen.dart
git commit -m "feat: BayView — seamless quarter-slot column grid with FAB, placement mode, and fixture press-to-assign"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| `SlotItem` with `productId`, `productName`, `productSku`, `category`, `colorHex` | Task 1 |
| `hangLength` keyword table (pants 36", dress/coat 48", jacket/hoodie 30", shirt 30", bra 12") | Task 1 |
| `foldedHeight` table (hoodie 12", jacket 10", pants/dress 8", shirt 6", bra 4"); coat excluded | Task 1 |
| `autoSpanQuarters`, `shelfSpanQuarters` pure functions | Task 1 |
| Shelf clearance enforced (+1 quarter) | Task 1 |
| `PgRow.heightIn` default 24.0 | Task 2 |
| `PgSlot.nodeType`, `items`, `subRow`, `spanQuarters` | Task 3 |
| Back-compat: legacy `productId` → synthesised `items` | Task 3 |
| `placeFixture`, `removeFixture`, `addItemToSlot`, `removeItemFromSlot`, `setRowHeight` | Task 4 |
| Auto-size on add/remove | Task 4 |
| FAB → `FixturePickerSheet` → 4 tile options | Tasks 5, 8 |
| Press fixture → `ProductAssignmentSheet` | Tasks 6, 8 |
| Fit indicator in assignment sheet | Task 6 |
| Capacity indicator (N/6) | Task 6 |
| Remove fixture from sheet | Task 6 |
| `SlotCellWidget` type stripe + pill for all 4 types | Task 7 |
| Empty fixture illustration + "+ ADD" hint | Task 7 |
| Shoulder/faceout/ubar/shelf filled content | Task 7 |
| No row dividers; seamless continuous grid | Task 8 |
| Quarter-slot column layout with free placement | Task 8 |
| Placement-mode banner when a fixture type is pending | Task 8 |
| `_GridView` (table type) unchanged | Tasks 7, 8 |

**Placeholder scan:** None found. All steps include full Dart code.

**Type consistency:** `SlotItem` defined in Task 1, used consistently in Tasks 3, 4, 6, 7. `autoSpanQuarters`/`shelfSpanQuarters` defined in Task 1, imported in Task 4. `placeFixture(col, subRow, nodeType)` defined in Task 4, called in Task 8. `addItemToSlot(col, subRow, SlotItem)` defined in Task 4, called in Task 6. All consistent.
