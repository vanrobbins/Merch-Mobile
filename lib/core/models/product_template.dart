import 'package:cloud_firestore/cloud_firestore.dart';

class ProductTemplate {
  const ProductTemplate({
    required this.id,
    required this.name,
    required this.silhouetteType,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String silhouetteType;
  final DateTime updatedAt;

  factory ProductTemplate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ProductTemplate(
      id: doc.id,
      name: d['name'] as String,
      silhouetteType: d['silhouetteType'] as String,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'silhouetteType': silhouetteType,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ProductTemplate copyWith({
    String? name,
    String? silhouetteType,
    DateTime? updatedAt,
  }) => ProductTemplate(
    id: id,
    name: name ?? this.name,
    silhouetteType: silhouetteType ?? this.silhouetteType,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
