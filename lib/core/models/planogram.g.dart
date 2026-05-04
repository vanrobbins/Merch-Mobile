// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanogramImpl _$$PlanogramImplFromJson(Map<String, dynamic> json) =>
    _$PlanogramImpl(
      id: json['id'] as String,
      fixtureId: json['fixtureId'] as String?,
      title: json['title'] as String,
      season: json['season'] as String,
      planogramType: json['planogramType'] as String? ?? 'shelf',
      rows: (json['rows'] as num?)?.toInt() ?? 2,
      cols: (json['cols'] as num?)?.toInt() ?? 4,
      linearFt: (json['linearFt'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'draft',
      slotsJson: json['slotsJson'] as String? ?? '',
      rowsJson: json['rowsJson'] as String? ?? '',
      looksJson: json['looksJson'] as String? ?? '',
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanogramImplToJson(_$PlanogramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fixtureId': instance.fixtureId,
      'title': instance.title,
      'season': instance.season,
      'planogramType': instance.planogramType,
      'rows': instance.rows,
      'cols': instance.cols,
      'linearFt': instance.linearFt,
      'status': instance.status,
      'slotsJson': instance.slotsJson,
      'rowsJson': instance.rowsJson,
      'looksJson': instance.looksJson,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
