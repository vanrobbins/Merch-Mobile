import 'package:freezed_annotation/freezed_annotation.dart';
import 'planogram_slot.dart';

part 'planogram.freezed.dart';
part 'planogram.g.dart';

@freezed
class Planogram with _$Planogram {
  const factory Planogram({
    required String id,
    required String fixtureId,
    required String title,
    required String season,
    @Default('draft') String status,
    @Default(<PlanogramSlot>[]) List<PlanogramSlot> slots,
    DateTime? publishedAt,
    required DateTime updatedAt,
  }) = _Planogram;

  factory Planogram.fromJson(Map<String, dynamic> json) => _$PlanogramFromJson(json);
}
