import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default('') String slotsJson,
    DateTime? publishedAt,
    required DateTime updatedAt,
  }) = _Planogram;

  factory Planogram.fromJson(Map<String, dynamic> json) =>
      _$PlanogramFromJson(json);
}

extension PlanogramFirestore on Planogram {
  static Planogram fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Planogram(
      id: doc.id,
      fixtureId: d['fixtureId'] as String,
      title: d['title'] as String,
      season: d['season'] as String,
      status: d['status'] as String? ?? 'draft',
      slotsJson: d['slotsJson'] as String? ?? '',
      publishedAt: d['publishedAt'] != null
          ? (d['publishedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fixtureId': fixtureId,
    'title': title,
    'season': season,
    'status': status,
    'slotsJson': slotsJson,
    if (publishedAt != null)
      'publishedAt': Timestamp.fromDate(publishedAt!),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
