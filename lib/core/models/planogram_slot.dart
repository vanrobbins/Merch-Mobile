import 'package:freezed_annotation/freezed_annotation.dart';

part 'planogram_slot.freezed.dart';
part 'planogram_slot.g.dart';

@freezed
class PlanogramSlot with _$PlanogramSlot {
  const factory PlanogramSlot({
    required String id,
    required String productId,
    required int sequence,
    @Default(1) int facings,
  }) = _PlanogramSlot;

  factory PlanogramSlot.fromJson(Map<String, dynamic> json) => _$PlanogramSlotFromJson(json);
}
