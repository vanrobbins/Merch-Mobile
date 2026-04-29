import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformElement {
  const PlatformElement({
    required this.id,
    required this.storeId,
    required this.zoneId,
    required this.width,
    required this.depth,
    required this.elevation,
    required this.positionX,
    required this.positionY,
    this.rotation = 0.0,
    this.colorHex = '#CCCCCC',
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String zoneId;
  final double width;
  final double depth;
  final double elevation;
  final double positionX;
  final double positionY;
  final double rotation;
  final String colorHex;
  final DateTime updatedAt;

  factory PlatformElement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PlatformElement(
      id: doc.id,
      storeId: d['storeId'] as String,
      zoneId: d['zoneId'] as String,
      width: (d['width'] as num).toDouble(),
      depth: (d['depth'] as num).toDouble(),
      elevation: (d['elevation'] as num?)?.toDouble() ?? 0.0,
      positionX: (d['positionX'] as num).toDouble(),
      positionY: (d['positionY'] as num).toDouble(),
      rotation: (d['rotation'] as num?)?.toDouble() ?? 0.0,
      colorHex: d['colorHex'] as String? ?? '#CCCCCC',
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'storeId': storeId,
    'zoneId': zoneId,
    'width': width,
    'depth': depth,
    'elevation': elevation,
    'positionX': positionX,
    'positionY': positionY,
    'rotation': rotation,
    'colorHex': colorHex,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  PlatformElement copyWith({
    double? width, double? depth, double? elevation,
    double? positionX, double? positionY, double? rotation,
    String? colorHex,
  }) => PlatformElement(
    id: id, storeId: storeId, zoneId: zoneId,
    width: width ?? this.width,
    depth: depth ?? this.depth,
    elevation: elevation ?? this.elevation,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    rotation: rotation ?? this.rotation,
    colorHex: colorHex ?? this.colorHex,
    updatedAt: DateTime.now(),
  );
}
