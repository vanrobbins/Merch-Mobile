import 'package:cloud_firestore/cloud_firestore.dart';

class Mannequin {
  const Mannequin({
    required this.id,
    required this.storeId,
    required this.zoneId,
    this.name,
    required this.mannequinType,
    required this.mountType,
    this.platformId,
    required this.positionX,
    required this.positionY,
    this.rotation = 0.0,
    this.outfitName,
    this.outfitNotes,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String zoneId;
  final String? name;
  // full_body | half_body | torso | leg_form | bra_form | bag_stand | hat_stand
  final String mannequinType;
  // floor | wall | platform
  final String mountType;
  final String? platformId;
  final double positionX;
  final double positionY;
  final double rotation;
  final String? outfitName;
  final String? outfitNotes;
  final DateTime updatedAt;

  factory Mannequin.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Mannequin(
      id: doc.id,
      storeId: d['storeId'] as String,
      zoneId: d['zoneId'] as String,
      name: d['name'] as String?,
      mannequinType: d['mannequinType'] as String,
      mountType: d['mountType'] as String? ?? 'floor',
      platformId: d['platformId'] as String?,
      positionX: (d['positionX'] as num).toDouble(),
      positionY: (d['positionY'] as num).toDouble(),
      rotation: (d['rotation'] as num?)?.toDouble() ?? 0.0,
      outfitName: d['outfitName'] as String?,
      outfitNotes: d['outfitNotes'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'storeId': storeId,
    'zoneId': zoneId,
    if (name != null) 'name': name,
    'mannequinType': mannequinType,
    'mountType': mountType,
    if (platformId != null) 'platformId': platformId,
    'positionX': positionX,
    'positionY': positionY,
    'rotation': rotation,
    if (outfitName != null) 'outfitName': outfitName,
    if (outfitNotes != null) 'outfitNotes': outfitNotes,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Mannequin copyWith({
    String? name,
    String? mannequinType,
    String? mountType,
    String? platformId,
    double? positionX,
    double? positionY,
    double? rotation,
    String? outfitName,
    String? outfitNotes,
  }) => Mannequin(
    id: id,
    storeId: storeId,
    zoneId: zoneId,
    name: name ?? this.name,
    mannequinType: mannequinType ?? this.mannequinType,
    mountType: mountType ?? this.mountType,
    platformId: platformId ?? this.platformId,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    rotation: rotation ?? this.rotation,
    outfitName: outfitName ?? this.outfitName,
    outfitNotes: outfitNotes ?? this.outfitNotes,
    updatedAt: DateTime.now(),
  );
}
