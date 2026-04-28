// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreMembershipImpl _$$StoreMembershipImplFromJson(
        Map<String, dynamic> json) =>
    _$StoreMembershipImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      uid: json['uid'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      displayName: json['displayName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$StoreMembershipImplToJson(
        _$StoreMembershipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'uid': instance.uid,
      'role': instance.role,
      'status': instance.status,
      'displayName': instance.displayName,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
