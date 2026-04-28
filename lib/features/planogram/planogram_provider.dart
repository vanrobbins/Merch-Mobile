// ignore_for_file: deprecated_member_use_from_same_package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/planogram.dart';
import '../../core/models/planogram_proposal.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'planogram_slot.dart';

part 'planogram_provider.g.dart';

@riverpod
Stream<List<Planogram>> planogramList(PlanogramListRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null || storeId.isEmpty) return Stream.value([]);
  return FirestoreRefs.planograms(storeId)
      .snapshots()
      .map((s) => s.docs.map(PlanogramFirestore.fromDoc).toList());
}

@riverpod
Stream<Planogram?> planogramDetail(PlanogramDetailRef ref, String planogramId) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.planograms(storeId).doc(planogramId).snapshots().map(
    (s) => s.exists ? PlanogramFirestore.fromDoc(s) : null,
  );
}

@riverpod
Stream<List<PlanogramProposal>> proposalList(ProposalListRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.proposals(storeId)
      .snapshots()
      .map((s) => s.docs
          .map((d) => PlanogramProposalFirestore.fromDoc(d, storeId))
          .toList());
}

@riverpod
class PlanogramEditor extends _$PlanogramEditor {
  @override
  List<PgSlot> build(String planogramId) => const [];

  void loadSlots(String slotsJson) {
    var slots = PgSlot.decodeList(slotsJson);
    if (slots.isEmpty) slots = PgSlot.defaults(6);
    state = slots;
  }

  void assignProduct(String slotId, String productId, String name, String sku) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return s.copyWith(productId: productId, productName: name, productSku: sku);
    }).toList();
  }

  void clearSlot(String slotId) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return PgSlot(id: s.id, position: s.position);
    }).toList();
  }

  Future<void> save(String planogramId) async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await FirestoreRefs.planograms(storeId).doc(planogramId).update({
      'slotsJson': PgSlot.encodeList(state),
      'updatedAt': Timestamp.now(),
    });
  }
}

// --- Write helpers ---

Future<void> upsertPlanogram(String storeId, Planogram planogram) async {
  await FirestoreRefs.planograms(storeId)
      .doc(planogram.id)
      .set(planogram.toFirestore(), SetOptions(merge: true));
}

Future<void> approvePlanogram(String storeId, String planogramId) async {
  await FirestoreRefs.planograms(storeId).doc(planogramId).update({
    'status': 'published',
    'publishedAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}

Future<void> updateProposalStatus(
    String storeId, String proposalId, String status, String reviewerUid) async {
  await FirestoreRefs.proposals(storeId).doc(proposalId).update({
    'status': status,
    'reviewedByUid': reviewerUid,
    'reviewedAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}
