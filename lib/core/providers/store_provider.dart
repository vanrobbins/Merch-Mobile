import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store.dart';
import '../models/store_membership.dart';
import '../services/firestore_refs.dart';
import 'auth_provider.dart';

part 'store_provider.g.dart';

const _kActiveStoreKey = 'active_store_id';

@Riverpod(keepAlive: true)
class ActiveStoreId extends _$ActiveStoreId {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveStoreKey);
  }

  Future<void> setStore(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveStoreKey, storeId);
    state = AsyncValue.data(storeId);
  }

  Future<void> clearStore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveStoreKey);
    state = const AsyncValue.data(null);
  }
}

/// The full Store record for the active store ID.
@riverpod
Stream<Store?> activeStore(Ref ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.store(storeId).snapshots().map(
    (snap) {
      if (!snap.exists) {
        // Stale storeId in SharedPreferences (e.g. from pre-Firestore SQLite
        // data). Clear it so the router redirects to the store gate.
        Future.microtask(
            () => ref.read(activeStoreIdProvider.notifier).clearStore());
        return null;
      }
      return StoreFirestore.fromDoc(snap);
    },
  );
}

/// The current user's active membership in the active store.
@riverpod
Stream<StoreMembership?> currentMembership(Ref ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirestoreRefs.memberships(storeId).doc(user.uid).snapshots().map(
    (snap) {
      if (!snap.exists) return null;
      // Migrate existing docs that pre-date the uid field (needed for collection group query).
      if (snap.data()?['uid'] == null) {
        Future.microtask(() => snap.reference.update({'uid': snap.id}));
      }
      final m = StoreMembershipFirestore.fromDoc(snap, storeId);
      return m.status == 'active' ? m : null;
    },
  );
}

/// All stores where the current user has an active membership.
/// Primary source: /userStores/{uid} document (fast, no index needed).
/// Migration path: if that document is empty, falls back to a collection group
/// query and bootstraps the document so future loads skip it.
@riverpod
Stream<List<Store>> myStores(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirestoreRefs.userStores(user.uid).snapshots().asyncMap((snap) async {
    final storeIds = List<String>.from(
        snap.data()?['activeStoreIds'] as List? ?? []);

    final stores = <Store>[];
    for (final storeId in storeIds) {
      final storeSnap = await FirestoreRefs.store(storeId).get();
      if (storeSnap.exists) stores.add(StoreFirestore.fromDoc(storeSnap));
    }
    return stores;
  });
}
