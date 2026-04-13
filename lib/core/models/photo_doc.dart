import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_doc.freezed.dart';
part 'photo_doc.g.dart';

@freezed
class PhotoDoc with _$PhotoDoc {
  const factory PhotoDoc({
    required String id,
    required String fixtureId,
    required String phase, // before/after
    required String localPath,
    @Default('') String remoteUrl,
    @Default('pending') String uploadStatus,
    @Default('pending') String approvalStatus,
    String? planogramId,
    required DateTime capturedAt,
    required DateTime updatedAt,
  }) = _PhotoDoc;

  factory PhotoDoc.fromJson(Map<String, dynamic> json) => _$PhotoDocFromJson(json);
}
