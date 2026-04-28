import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planogram_proposal.freezed.dart';
part 'planogram_proposal.g.dart';

@freezed
class PlanogramProposal with _$PlanogramProposal {
  const factory PlanogramProposal({
    required String id,
    required String planogramId,
    required String storeId,
    required String proposedByUid,
    @Default('pending') String status,
    @Default('') String notes,
    @Default('') String slotChanges,
    String? reviewedByUid,
    DateTime? reviewedAt,
    required DateTime updatedAt,
  }) = _PlanogramProposal;

  factory PlanogramProposal.fromJson(Map<String, dynamic> json) =>
      _$PlanogramProposalFromJson(json);
}

extension PlanogramProposalFirestore on PlanogramProposal {
  static PlanogramProposal fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String storeId,
  ) {
    final d = doc.data()!;
    return PlanogramProposal(
      id: doc.id,
      planogramId: d['planogramId'] as String,
      storeId: storeId,
      proposedByUid: d['proposedByUid'] as String,
      status: d['status'] as String? ?? 'pending',
      notes: d['notes'] as String? ?? '',
      slotChanges: d['slotChanges'] as String? ?? '',
      reviewedByUid: d['reviewedByUid'] as String?,
      reviewedAt: d['reviewedAt'] != null
          ? (d['reviewedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'planogramId': planogramId,
    'proposedByUid': proposedByUid,
    'status': status,
    'notes': notes,
    'slotChanges': slotChanges,
    if (reviewedByUid != null) 'reviewedByUid': reviewedByUid,
    if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
