// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreGroupImpl _$$StoreGroupImplFromJson(Map<String, dynamic> json) =>
    _$StoreGroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdByUid: json['createdByUid'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$$StoreGroupImplToJson(_$StoreGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdByUid': instance.createdByUid,
      'createdAt': instance.createdAt,
    };
