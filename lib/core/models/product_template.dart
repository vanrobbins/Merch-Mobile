import 'package:cloud_firestore/cloud_firestore.dart';

class ProductTemplate {
  const ProductTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.silhouetteType,
    required this.isDefault,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  // shirt_ss | shirt_ls | tank_top | pant | short | jacket |
  // dress | skirt | bag | hat | bra | shoe | other
  final String silhouetteType;
  final bool isDefault;
  final DateTime updatedAt;

  String get assetPath => 'assets/silhouettes/$silhouetteType.svg';

  factory ProductTemplate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ProductTemplate(
      id: doc.id,
      name: d['name'] as String,
      category: d['category'] as String? ?? 'Other',
      silhouetteType: d['silhouetteType'] as String,
      isDefault: d['isDefault'] as bool? ?? false,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'silhouetteType': silhouetteType,
    'isDefault': isDefault,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ProductTemplate copyWith({
    String? name,
    String? category,
    String? silhouetteType,
    bool? isDefault,
    DateTime? updatedAt,
  }) => ProductTemplate(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    silhouetteType: silhouetteType ?? this.silhouetteType,
    isDefault: isDefault ?? this.isDefault,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
