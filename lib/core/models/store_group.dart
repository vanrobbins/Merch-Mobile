import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_group.freezed.dart';
part 'store_group.g.dart';

@freezed
class StoreGroup with _$StoreGroup {
  const factory StoreGroup({
    required String id,
    required String name,
    String? description,
    required String createdByUid,
    required int createdAt,
  }) = _StoreGroup;

  factory StoreGroup.fromJson(Map<String, dynamic> json) =>
      _$StoreGroupFromJson(json);
}
