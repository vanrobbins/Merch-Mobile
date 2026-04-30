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
