import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String sku,
    required String name,
    required String category,
    @Default('') String imageUrl,
    @Default(<String>[]) List<String> sizes,
    @Default(0) int stockQty,
    String? colorId,
    String? templateId,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

extension ProductFirestore on Product {
  static Product fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      sku: d['sku'] as String,
      name: d['name'] as String,
      category: d['category'] as String,
      imageUrl: d['imageUrl'] as String? ?? '',
      sizes: List<String>.from(d['sizes'] as List? ?? []),
      stockQty: d['stockQty'] as int? ?? 0,
      colorId: d['colorId'] as String?,
      templateId: d['templateId'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sku': sku,
    'name': name,
    'category': category,
    'imageUrl': imageUrl,
    'sizes': sizes,
    'stockQty': stockQty,
    if (colorId != null) 'colorId': colorId,
    if (templateId != null) 'templateId': templateId,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
