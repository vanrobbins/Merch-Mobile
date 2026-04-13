// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planogram_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanogramSlotImpl _$$PlanogramSlotImplFromJson(Map<String, dynamic> json) =>
    _$PlanogramSlotImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      sequence: (json['sequence'] as num).toInt(),
      facings: (json['facings'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$PlanogramSlotImplToJson(_$PlanogramSlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'sequence': instance.sequence,
      'facings': instance.facings,
    };
