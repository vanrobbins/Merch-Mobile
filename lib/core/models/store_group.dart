import 'package:cloud_firestore/cloud_firestore.dart';
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

extension StoreGroupFirestore on StoreGroup {
  static StoreGroup fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StoreGroup(
      id: doc.id,
      name: d['name'] as String,
      description: d['description'] as String?,
      createdByUid: d['createdByUid'] as String? ?? '',
      createdAt: (d['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    if (description != null) 'description': description,
    'createdByUid': createdByUid,
    'createdAt': createdAt,
  };
}
