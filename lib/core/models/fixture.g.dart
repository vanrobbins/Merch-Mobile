// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FixtureImpl _$$FixtureImplFromJson(Map<String, dynamic> json) =>
    _$FixtureImpl(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      fixtureType: json['fixtureType'] as String,
      posX: (json['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (json['posY'] as num?)?.toDouble() ?? 0.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      widthFt: (json['widthFt'] as num?)?.toDouble() ?? 4.0,
      depthFt: (json['depthFt'] as num?)?.toDouble() ?? 2.0,
      label: json['label'] as String? ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FixtureImplToJson(_$FixtureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zoneId': instance.zoneId,
      'fixtureType': instance.fixtureType,
      'posX': instance.posX,
      'posY': instance.posY,
      'rotation': instance.rotation,
      'widthFt': instance.widthFt,
      'depthFt': instance.depthFt,
      'label': instance.label,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
