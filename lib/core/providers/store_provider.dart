import 'package:cloud_firestore/cloud_firestore.dart';
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
Stream<Store?> activeStore(ActiveStoreRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.store(storeId).snapshots().map(
    (snap) => snap.exists ? StoreFirestore.fromDoc(snap) : null,
  );
}

/// The current user's active membership in the active store.
@riverpod
Stream<StoreMembership?> currentMembership(CurrentMembershipRef ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirestoreRefs.memberships(storeId).doc(user.uid).snapshots().map(
    (snap) {
      if (!snap.exists) return null;
      final m = StoreMembershipFirestore.fromDoc(snap, storeId);
      return m.status == 'active' ? m : null;
    },
  );
}

/// All stores where the current user has an active membership.
@riverpod
Stream<List<Store>> myStores(MyStoresRef ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collectionGroup('memberships')
      .where(FieldPath.documentId, isEqualTo: user.uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .asyncMap((snap) async {
    final stores = <Store>[];
    for (final memberDoc in snap.docs) {
      final storeRef = memberDoc.reference.parent.parent!;
      final storeSnap = await storeRef.get();
      if (storeSnap.exists) {
        stores.add(StoreFirestore.fromDoc(storeSnap));
      }
    }
    return stores;
  });
}
