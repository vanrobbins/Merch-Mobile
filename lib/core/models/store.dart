import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String id,
    required String name,
    required String inviteCode,
    required String ownerUid,
    double? widthFt,
    double? depthFt,
    String? entranceJson,
    required DateTime createdAt,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}

extension StoreFirestore on Store {
  static Store fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Store(
      id: doc.id,
      name: d['name'] as String,
      inviteCode: d['inviteCode'] as String,
      ownerUid: d['ownerUid'] as String,
      widthFt: (d['widthFt'] as num?)?.toDouble(),
      depthFt: (d['depthFt'] as num?)?.toDouble(),
      entranceJson: d['entranceJson'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'inviteCode': inviteCode,
    'ownerUid': ownerUid,
    if (widthFt != null) 'widthFt': widthFt,
    if (depthFt != null) 'depthFt': depthFt,
    if (entranceJson != null) 'entranceJson': entranceJson,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
