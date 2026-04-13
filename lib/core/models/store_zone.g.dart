// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreZoneImpl _$$StoreZoneImplFromJson(Map<String, dynamic> json) =>
    _$StoreZoneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
      zoneType: json['zoneType'] as String,
      storeId: json['storeId'] as String,
      posX: (json['posX'] as num?)?.toDouble() ?? 0.0,
      posY: (json['posY'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.2,
      height: (json['height'] as num?)?.toDouble() ?? 0.2,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StoreZoneImplToJson(_$StoreZoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorValue': instance.colorValue,
      'zoneType': instance.zoneType,
      'storeId': instance.storeId,
      'posX': instance.posX,
      'posY': instance.posY,
      'width': instance.width,
      'height': instance.height,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
