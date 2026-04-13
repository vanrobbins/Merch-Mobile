// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoDocImpl _$$PhotoDocImplFromJson(Map<String, dynamic> json) =>
    _$PhotoDocImpl(
      id: json['id'] as String,
      fixtureId: json['fixtureId'] as String,
      phase: json['phase'] as String,
      localPath: json['localPath'] as String,
      remoteUrl: json['remoteUrl'] as String? ?? '',
      uploadStatus: json['uploadStatus'] as String? ?? 'pending',
      approvalStatus: json['approvalStatus'] as String? ?? 'pending',
      planogramId: json['planogramId'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PhotoDocImplToJson(_$PhotoDocImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fixtureId': instance.fixtureId,
      'phase': instance.phase,
      'localPath': instance.localPath,
      'remoteUrl': instance.remoteUrl,
      'uploadStatus': instance.uploadStatus,
      'approvalStatus': instance.approvalStatus,
      'planogramId': instance.planogramId,
      'capturedAt': instance.capturedAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
