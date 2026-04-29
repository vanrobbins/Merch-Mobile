import 'package:cloud_firestore/cloud_firestore.dart';

class SceneProp {
  const SceneProp({
    required this.id,
    required this.storeId,
    required this.zoneId,
    required this.propType,
    required this.name,
    required this.positionX,
    required this.positionY,
    this.rotation = 0.0,
    required this.width,
    required this.depth,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String zoneId;
  // plant | furniture | riser | signage | other
  final String propType;
  final String name;
  final double positionX;
  final double positionY;
  final double rotation;
  final double width;
  final double depth;
  final DateTime updatedAt;

  factory SceneProp.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SceneProp(
      id: doc.id,
      storeId: d['storeId'] as String,
      zoneId: d['zoneId'] as String,
      propType: d['propType'] as String,
      name: d['name'] as String,
      positionX: (d['positionX'] as num).toDouble(),
      positionY: (d['positionY'] as num).toDouble(),
      rotation: (d['rotation'] as num?)?.toDouble() ?? 0.0,
      width: (d['width'] as num).toDouble(),
      depth: (d['depth'] as num).toDouble(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'storeId': storeId,
    'zoneId': zoneId,
    'propType': propType,
    'name': name,
    'positionX': positionX,
    'positionY': positionY,
    'rotation': rotation,
    'width': width,
    'depth': depth,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  SceneProp copyWith({
    String? propType, String? name,
    double? positionX, double? positionY, double? rotation,
    double? width, double? depth,
  }) => SceneProp(
    id: id, storeId: storeId, zoneId: zoneId,
    propType: propType ?? this.propType,
    name: name ?? this.name,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    rotation: rotation ?? this.rotation,
    width: width ?? this.width,
    depth: depth ?? this.depth,
    updatedAt: DateTime.now(),
  );
}
