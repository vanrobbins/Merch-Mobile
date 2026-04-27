import 'dart:convert';

/// A slot in a planogram — stored as JSON in PlanogramsTable.slotsJson.
///
/// Feature-scoped model, kept separate from `core/models/planogram_slot.dart`
/// (v0.1 shape with required productId and sequence/facings). This richer
/// v0.2 shape is what the editor, proposal flow, and dashboard use to show
/// product name + SKU inside slot cards. `fromJson` accepts either 'position'
/// or legacy 'sequence' so old rows still load.
class PgSlot {
  final String id;
  final int position; // 1-based index
  final String? productId;
  final String? productName;
  final String? productSku;

  const PgSlot({
    required this.id,
    required this.position,
    this.productId,
    this.productName,
    this.productSku,
  });

  PgSlot copyWith({
    String? productId,
    String? productName,
    String? productSku,
  }) =>
      PgSlot(
        id: id,
        position: position,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        productSku: productSku ?? this.productSku,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'productId': productId,
        'productName': productName,
        'productSku': productSku,
      };

  factory PgSlot.fromJson(Map<String, dynamic> json) => PgSlot(
        id: json['id'] as String,
        // Accept either v0.2 'position' or v0.1 'sequence' for back-compat.
        position: (json['position'] ?? json['sequence'] ?? 1) as int,
        productId: json['productId'] as String?,
        productName: json['productName'] as String?,
        productSku: json['productSku'] as String?,
      );

  static String encodeList(List<PgSlot> slots) =>
      jsonEncode(slots.map((s) => s.toJson()).toList());

  static List<PgSlot> decodeList(String json) {
    if (json.isEmpty || json == '[]') return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PgSlot.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Generate a default set of empty slots.
  static List<PgSlot> defaults(int count) => List.generate(
        count,
        (i) => PgSlot(id: 'slot_${i + 1}', position: i + 1),
      );
}
