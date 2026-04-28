// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram_proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanogramProposalImpl _$$PlanogramProposalImplFromJson(
        Map<String, dynamic> json) =>
    _$PlanogramProposalImpl(
      id: json['id'] as String,
      planogramId: json['planogramId'] as String,
      storeId: json['storeId'] as String,
      proposedByUid: json['proposedByUid'] as String,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String? ?? '',
      slotChanges: json['slotChanges'] as String? ?? '',
      reviewedByUid: json['reviewedByUid'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PlanogramProposalImplToJson(
        _$PlanogramProposalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planogramId': instance.planogramId,
      'storeId': instance.storeId,
      'proposedByUid': instance.proposedByUid,
      'status': instance.status,
      'notes': instance.notes,
      'slotChanges': instance.slotChanges,
      'reviewedByUid': instance.reviewedByUid,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
