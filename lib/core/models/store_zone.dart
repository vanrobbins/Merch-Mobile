import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_zone.freezed.dart';
part 'store_zone.g.dart';

@freezed
class StoreZone with _$StoreZone {
  const factory StoreZone({
    required String id,
    required String name,
    required int colorValue,
    required String zoneType,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.2) double width,
    @Default(0.2) double height,
    String? shapePoints,
    @Default(false) bool positionLocked,
    required DateTime updatedAt,
  }) = _StoreZone;

  factory StoreZone.fromJson(Map<String, dynamic> json) =>
      _$StoreZoneFromJson(json);
}

extension StoreZoneFirestore on StoreZone {
  static StoreZone fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StoreZone(
      id: doc.id,
      name: d['name'] as String,
      colorValue: d['colorValue'] as int,
      zoneType: d['zoneType'] as String,
      posX: (d['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (d['posY'] as num?)?.toDouble() ?? 0.0,
      width: (d['width'] as num?)?.toDouble() ?? 0.2,
      height: (d['height'] as num?)?.toDouble() ?? 0.2,
      shapePoints: d['shapePoints'] as String?,
      positionLocked: d['positionLocked'] as bool? ?? false,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'colorValue': colorValue,
    'zoneType': zoneType,
    'posX': posX,
    'posY': posY,
    'width': width,
    'height': height,
    if (shapePoints != null) 'shapePoints': shapePoints,
    'positionLocked': positionLocked,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
