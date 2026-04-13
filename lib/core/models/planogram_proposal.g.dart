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
      proposedAt: (json['proposedAt'] as num).toInt(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      slotChanges: json['slotChanges'] as String?,
      reviewedByUid: json['reviewedByUid'] as String?,
      reviewedAt: (json['reviewedAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PlanogramProposalImplToJson(
        _$PlanogramProposalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planogramId': instance.planogramId,
      'storeId': instance.storeId,
      'proposedByUid': instance.proposedByUid,
      'proposedAt': instance.proposedAt,
      'status': instance.status,
      'notes': instance.notes,
      'slotChanges': instance.slotChanges,
      'reviewedByUid': instance.reviewedByUid,
      'reviewedAt': instance.reviewedAt,
    };
