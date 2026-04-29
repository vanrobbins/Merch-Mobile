import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planogram.freezed.dart';
part 'planogram.g.dart';

@freezed
class Planogram with _$Planogram {
  const factory Planogram({
    required String id,
    String? fixtureId,                        // nullable — standalone planograms allowed
    required String title,
    required String season,
    @Default('shelf') String planogramType,   // 'wall' | 'shelf' | 'table' | 'rack'
    @Default(2) int rows,
    @Default(4) int cols,
    double? linearFt,                         // wall/shelf only
    @Default('draft') String status,
    @Default('') String slotsJson,
    @Default('') String rowsJson,
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
      fixtureId: d['fixtureId'] as String?,
      title: d['title'] as String,
      season: d['season'] as String,
      planogramType: d['planogramType'] as String? ?? 'shelf',
      rows: (d['rows'] as num?)?.toInt() ?? 2,
      cols: (d['cols'] as num?)?.toInt() ?? 4,
      linearFt: (d['linearFt'] as num?)?.toDouble(),
      status: d['status'] as String? ?? 'draft',
      slotsJson: d['slotsJson'] as String? ?? '',
      rowsJson: d['rowsJson'] as String? ?? '',
      publishedAt: d['publishedAt'] != null
          ? (d['publishedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        if (fixtureId != null) 'fixtureId': fixtureId,
        'title': title,
        'season': season,
        'planogramType': planogramType,
        'rows': rows,
        'cols': cols,
        if (linearFt != null) 'linearFt': linearFt,
        'status': status,
        'slotsJson': slotsJson,
        'rowsJson': rowsJson,
        if (publishedAt != null)
          'publishedAt': Timestamp.fromDate(publishedAt!),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
