import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';

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
    @Default(0) int pendingPhotoApprovals,
    @Default(0) int myPhotoCount,
    @Default(0) int myProposalCount,
  }) = _DashboardStats;
}

/// Live dashboard stats for the active store, scoped to the current
/// membership's role. Staff see their own counts; coordinator/manager see
/// store-wide counts and pending queues.
@riverpod
Stream<DashboardStats> dashboardStats(DashboardStatsRef ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final storeId = ref.watch(activeStoreIdProvider).value;
  final membership = ref.watch(currentMembershipProvider).value;
  final user = ref.watch(authStateProvider).value;

  if (storeId == null || storeId.isEmpty || membership == null) {
    yield const DashboardStats();
    return;
  }

  // Drive off the zones stream as the "tick" — re-emit aggregated stats
  // whenever zones change. Other counts are snapshotted via .first each tick.
  await for (final zones in db.zonesDao.watchByStore(storeId)) {
    final fixtures =
        await db.fixturesDao.watchByStore(storeId).first;
    final products =
        await db.productsDao.watchByStore(storeId).first;
    final pendingMembers =
        await db.storeMembershipsDao.watchPending(storeId).first;
    final pendingProposals =
        await db.planogramProposalsDao.watchPendingByStore(storeId).first;

    // "My" counts for the staff view.
    // Photos are not attributed to a specific uploader in the schema,
    // so "my photos" falls back to "photos in this store" for now.
    int myPhotoCount = 0;
    int myProposalCount = 0;
    final allPhotos = await db.photoDocsDao.watchAll().first;
    myPhotoCount =
        allPhotos.where((p) => p.storeId == storeId).length;
    if (user != null) {
      final myProposals = await db.planogramProposalsDao
          .watchByUser(storeId, user.uid)
          .first;
      myProposalCount = myProposals.length;
    }

    yield DashboardStats(
      zoneCount: zones.length,
      fixtureCount: fixtures.length,
      productCount: products.length,
      pendingJoinRequests: pendingMembers.length,
      pendingProposals: pendingProposals.length,
      myPhotoCount: myPhotoCount,
      myProposalCount: myProposalCount,
    );
  }
}
