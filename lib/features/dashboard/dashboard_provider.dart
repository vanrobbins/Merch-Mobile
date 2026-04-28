import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'dashboard_provider.freezed.dart';
part 'dashboard_provider.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int zoneCount,
    @Default(0) int fixtureCount,
    @Default(0) int productCount,
    @Default(0) int pendingJoinRequests,
    @Default(0) int pendingProposals,
    @Default(0) int myPhotoCount,
    @Default(0) int myProposalCount,
  }) = _DashboardStats;
}

@riverpod
Stream<DashboardStats> dashboardStats(DashboardStatsRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  final membership = ref.watch(currentMembershipProvider).value;
  final user = ref.watch(authStateProvider).value;

  if (storeId == null || storeId.isEmpty || membership == null) {
    return Stream.value(const DashboardStats());
  }

  // Use asyncMap so in-flight futures are properly scoped to each snapshot
  // event and errors are contained — avoids abandoned-await issues from
  // async*/await-for when this provider is rebuilt on store switch.
  return FirestoreRefs.zones(storeId).snapshots().asyncMap((zonesSnap) async {
    try {
      final fixturesSnap = await FirestoreRefs.fixtures(storeId).get();
      final productsSnap = await FirestoreRefs.products(storeId).get();
      final pendingMembersSnap = await FirestoreRefs.memberships(storeId)
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingProposalsSnap = await FirestoreRefs.proposals(storeId)
          .where('status', isEqualTo: 'pending')
          .get();
      final photosSnap = await FirestoreRefs.photos(storeId).get();

      int myProposalCount = 0;
      if (user != null) {
        final myProposalsSnap = await FirestoreRefs.proposals(storeId)
            .where('proposedByUid', isEqualTo: user.uid)
            .get();
        myProposalCount = myProposalsSnap.size;
      }

      return DashboardStats(
        zoneCount: zonesSnap.size,
        fixtureCount: fixturesSnap.size,
        productCount: productsSnap.size,
        pendingJoinRequests: pendingMembersSnap.size,
        pendingProposals: pendingProposalsSnap.size,
        myPhotoCount: photosSnap.size,
        myProposalCount: myProposalCount,
      );
    } catch (_) {
      return const DashboardStats();
    }
  });
}
