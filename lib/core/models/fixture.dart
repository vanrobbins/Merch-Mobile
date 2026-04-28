import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixture.freezed.dart';
part 'fixture.g.dart';

@freezed
class Fixture with _$Fixture {
  const factory Fixture({
    required String id,
    String? zoneId,
    required String fixtureType,
    @Default(0.0) double posX,
    @Default(0.0) double posY,
    @Default(0.0) double rotation,
    @Default(4.0) double widthFt,
    @Default(2.0) double depthFt,
    @Default('') String label,
    String? planogramId,
    String? planogramIdBack,
    @Default(false) bool wallAdjacent,
    @Default('floor') String mountType,
    @Default('full') String mannequinType,
    @Default(0.0) double positionX,
    @Default(0.0) double positionY,
    required DateTime updatedAt,
  }) = _Fixture;

  factory Fixture.fromJson(Map<String, dynamic> json) =>
      _$FixtureFromJson(json);
}

extension FixtureFirestore on Fixture {
  static Fixture fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Fixture(
      id: doc.id,
      zoneId: d['zoneId'] as String?,
      fixtureType: d['fixtureType'] as String,
      posX: (d['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (d['posY'] as num?)?.toDouble() ?? 0.0,
      rotation: (d['rotation'] as num?)?.toDouble() ?? 0.0,
      widthFt: (d['widthFt'] as num?)?.toDouble() ?? 4.0,
      depthFt: (d['depthFt'] as num?)?.toDouble() ?? 2.0,
      label: d['label'] as String? ?? '',
      planogramId: d['planogramId'] as String?,
      planogramIdBack: d['planogramIdBack'] as String?,
      wallAdjacent: d['wallAdjacent'] as bool? ?? false,
      mountType: d['mountType'] as String? ?? 'floor',
      mannequinType: d['mannequinType'] as String? ?? 'full',
      positionX: (d['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (d['positionY'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    if (zoneId != null) 'zoneId': zoneId,
    'fixtureType': fixtureType,
    'posX': posX,
    'posY': posY,
    'rotation': rotation,
    'widthFt': widthFt,
    'depthFt': depthFt,
    'label': label,
    if (planogramId != null) 'planogramId': planogramId,
    if (planogramIdBack != null) 'planogramIdBack': planogramIdBack,
    'wallAdjacent': wallAdjacent,
    'mountType': mountType,
    'mannequinType': mannequinType,
    'positionX': positionX,
    'positionY': positionY,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
