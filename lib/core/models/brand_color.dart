import 'package:cloud_firestore/cloud_firestore.dart';

class BrandColor {
  const BrandColor({
    required this.id,
    required this.name,
    required this.hexValue,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String hexValue;
  final DateTime updatedAt;

  factory BrandColor.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return BrandColor(
      id: doc.id,
      name: d['name'] as String,
      hexValue: d['hexValue'] as String,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'hexValue': hexValue,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  BrandColor copyWith({String? name, String? hexValue, DateTime? updatedAt}) =>
      BrandColor(
        id: id,
        name: name ?? this.name,
        hexValue: hexValue ?? this.hexValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
