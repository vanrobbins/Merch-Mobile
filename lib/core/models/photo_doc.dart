import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_doc.freezed.dart';
part 'photo_doc.g.dart';

@freezed
class PhotoDoc with _$PhotoDoc {
  const factory PhotoDoc({
    required String id,
    required String fixtureId,
    required String phase,
    String? localPath,
    String? remoteUrl,
    @Default('pending') String uploadStatus,
    @Default('none') String approvalStatus,
    String? planogramId,
    required String storeId,
    required DateTime capturedAt,
    required DateTime updatedAt,
  }) = _PhotoDoc;

  factory PhotoDoc.fromJson(Map<String, dynamic> json) =>
      _$PhotoDocFromJson(json);
}

extension PhotoDocFirestore on PhotoDoc {
  static PhotoDoc fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return PhotoDoc(
      id: doc.id,
      fixtureId: d['fixtureId'] as String,
      phase: d['phase'] as String,
      localPath: d['localPath'] as String?,
      remoteUrl: d['remoteUrl'] as String?,
      uploadStatus: d['uploadStatus'] as String? ?? 'pending',
      approvalStatus: d['approvalStatus'] as String? ?? 'none',
      planogramId: d['planogramId'] as String?,
      storeId: storeId,
      capturedAt: (d['capturedAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fixtureId': fixtureId,
    'phase': phase,
    if (localPath != null) 'localPath': localPath,
    if (remoteUrl != null) 'remoteUrl': remoteUrl,
    'uploadStatus': uploadStatus,
    'approvalStatus': approvalStatus,
    if (planogramId != null) 'planogramId': planogramId,
    'capturedAt': Timestamp.fromDate(capturedAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
