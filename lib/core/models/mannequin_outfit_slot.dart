import 'package:cloud_firestore/cloud_firestore.dart';

class MannequinOutfitSlot {
  const MannequinOutfitSlot({
    required this.id,
    required this.mannequinId,
    required this.bodySlot,
    this.productId,
    this.colorId,
    this.colorNotes,
    this.displayNotes,
    required this.updatedAt,
  });

  final String id;
  final String mannequinId;
  // head | torso | legs | feet | left_hand | right_hand | accessory_1 | accessory_2
  final String bodySlot;
  final String? productId;
  final String? colorId;
  final String? colorNotes;
  final String? displayNotes;
  final DateTime updatedAt;

  factory MannequinOutfitSlot.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MannequinOutfitSlot(
      id: doc.id,
      mannequinId: d['mannequinId'] as String,
      bodySlot: d['bodySlot'] as String,
      productId: d['productId'] as String?,
      colorId: d['colorId'] as String?,
      colorNotes: d['colorNotes'] as String?,
      displayNotes: d['displayNotes'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'mannequinId': mannequinId,
    'bodySlot': bodySlot,
    if (productId != null) 'productId': productId,
    if (colorId != null) 'colorId': colorId,
    if (colorNotes != null) 'colorNotes': colorNotes,
    if (displayNotes != null) 'displayNotes': displayNotes,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  MannequinOutfitSlot copyWith({
    String? productId,
    String? colorId,
    String? colorNotes,
    String? displayNotes,
  }) => MannequinOutfitSlot(
    id: id,
    mannequinId: mannequinId,
    bodySlot: bodySlot,
    productId: productId ?? this.productId,
    colorId: colorId ?? this.colorId,
    colorNotes: colorNotes ?? this.colorNotes,
    displayNotes: displayNotes ?? this.displayNotes,
    updatedAt: DateTime.now(),
  );
}
