import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_membership.freezed.dart';
part 'store_membership.g.dart';

@freezed
class StoreMembership with _$StoreMembership {
  const factory StoreMembership({
    required String id,
    required String storeId,
    required String userUid,
    required String role,      // coordinator | manager | staff
    required String displayName,
    required String status,    // pending | active | rejected
    required int joinedAt,
  }) = _StoreMembership;

  factory StoreMembership.fromJson(Map<String, dynamic> json) =>
      _$StoreMembershipFromJson(json);
}
