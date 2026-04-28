import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_membership.freezed.dart';
part 'store_membership.g.dart';

@freezed
class StoreMembership with _$StoreMembership {
  const factory StoreMembership({
    required String id,
    required String storeId,
    required String uid,
    required String role,
    required String status,
    required String displayName,
    required DateTime joinedAt,
  }) = _StoreMembership;

  factory StoreMembership.fromJson(Map<String, dynamic> json) =>
      _$StoreMembershipFromJson(json);
}

extension StoreMembershipFirestore on StoreMembership {
  static StoreMembership fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return StoreMembership(
      id: doc.id,
      storeId: storeId,
      uid: doc.id,
      role: d['role'] as String,
      status: d['status'] as String,
      displayName: d['displayName'] as String? ?? '',
      joinedAt: (d['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'role': role,
    'status': status,
    'displayName': displayName,
    'joinedAt': Timestamp.fromDate(joinedAt),
  };
}
