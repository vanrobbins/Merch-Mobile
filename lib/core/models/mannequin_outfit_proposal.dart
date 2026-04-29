import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MannequinOutfitProposal {
  const MannequinOutfitProposal({
    required this.id,
    required this.mannequinId,
    required this.storeId,
    required this.proposedByUid,
    required this.proposedByName,
    required this.proposedAt,
    required this.status,
    required this.slotChanges,
    this.notes,
    this.reviewedByUid,
    this.reviewedAt,
  });

  final String id;
  final String mannequinId;
  final String storeId;
  final String proposedByUid;
  final String proposedByName;
  final DateTime proposedAt;
  // pending | approved | rejected
  final String status;
  // JSON-encoded list of slot changes [{bodySlot, productId, colorId, colorNotes}]
  final String slotChanges;
  final String? notes;
  final String? reviewedByUid;
  final DateTime? reviewedAt;

  List<Map<String, dynamic>> get decodedSlotChanges =>
      List<Map<String, dynamic>>.from(jsonDecode(slotChanges) as List);

  factory MannequinOutfitProposal.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MannequinOutfitProposal(
      id: doc.id,
      mannequinId: d['mannequinId'] as String,
      storeId: d['storeId'] as String,
      proposedByUid: d['proposedByUid'] as String,
      proposedByName: d['proposedByName'] as String? ?? 'Staff',
      proposedAt: (d['proposedAt'] as Timestamp).toDate(),
      status: d['status'] as String,
      slotChanges: d['slotChanges'] as String,
      notes: d['notes'] as String?,
      reviewedByUid: d['reviewedByUid'] as String?,
      reviewedAt: d['reviewedAt'] != null
          ? (d['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'mannequinId': mannequinId,
    'storeId': storeId,
    'proposedByUid': proposedByUid,
    'proposedByName': proposedByName,
    'proposedAt': Timestamp.fromDate(proposedAt),
    'status': status,
    'slotChanges': slotChanges,
    if (notes != null) 'notes': notes,
    if (reviewedByUid != null) 'reviewedByUid': reviewedByUid,
    if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
  };
}
