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
