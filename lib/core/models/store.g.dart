// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      ownerUid: json['ownerUid'] as String,
      widthFt: (json['widthFt'] as num?)?.toDouble(),
      depthFt: (json['depthFt'] as num?)?.toDouble(),
      entranceJson: json['entranceJson'] as String?,
      shapePoints: json['shapePoints'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'inviteCode': instance.inviteCode,
      'ownerUid': instance.ownerUid,
      'widthFt': instance.widthFt,
      'depthFt': instance.depthFt,
      'entranceJson': instance.entranceJson,
      'shapePoints': instance.shapePoints,
      'createdAt': instance.createdAt.toIso8601String(),
    };
