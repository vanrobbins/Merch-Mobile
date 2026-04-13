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
    required int proposedAt,
    required String status, // pending | approved | rejected
    String? notes,
    String? slotChanges,    // JSON
    String? reviewedByUid,
    int? reviewedAt,
  }) = _PlanogramProposal;

  factory PlanogramProposal.fromJson(Map<String, dynamic> json) =>
      _$PlanogramProposalFromJson(json);
}
