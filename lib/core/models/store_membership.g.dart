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
      userUid: json['userUid'] as String,
      role: json['role'] as String,
      displayName: json['displayName'] as String,
      status: json['status'] as String,
      joinedAt: (json['joinedAt'] as num).toInt(),
    );

Map<String, dynamic> _$$StoreMembershipImplToJson(
        _$StoreMembershipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'userUid': instance.userUid,
      'role': instance.role,
      'displayName': instance.displayName,
      'status': instance.status,
      'joinedAt': instance.joinedAt,
    };
