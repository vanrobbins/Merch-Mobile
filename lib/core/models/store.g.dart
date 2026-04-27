// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreImpl _$$StoreImplFromJson(Map<String, dynamic> json) => _$StoreImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      ownerUid: json['ownerUid'] as String,
    );

Map<String, dynamic> _$$StoreImplToJson(_$StoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'inviteCode': instance.inviteCode,
      'createdAt': instance.createdAt,
      'ownerUid': instance.ownerUid,
    };
