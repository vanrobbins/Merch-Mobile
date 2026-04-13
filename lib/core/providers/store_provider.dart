import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

part 'store_provider.g.dart';

const _kActiveStoreKey = 'active_store_id';

/// The currently selected store ID. Persisted across launches.
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
Stream<StoresTableData?> activeStore(ActiveStoreRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final storeIdAsync = ref.watch(activeStoreIdProvider);
  final storeId = storeIdAsync.value;
  if (storeId == null) return Stream.value(null);
  return db.storesDao.watchAll().map(
    (list) => list.where((s) => s.id == storeId).firstOrNull,
  );
}

/// The current user's membership in the active store.
@riverpod
Stream<StoreMembershipsTableData?> currentMembership(
    CurrentMembershipRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final storeIdAsync = ref.watch(activeStoreIdProvider);
  final storeId = storeIdAsync.value;
  if (storeId == null) return Stream.value(null);

  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return db.storeMembershipsDao
      .watchByUser(user.uid)
      .map((list) => list
          .where((m) => m.storeId == storeId && m.status == 'active')
          .firstOrNull);
}

/// All stores the current user has an active membership in.
@riverpod
Stream<List<StoresTableData>> myStores(MyStoresRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return db.storeMembershipsDao.watchByUser(user.uid).asyncMap((memberships) async {
    final active = memberships.where((m) => m.status == 'active').toList();
    final stores = <StoresTableData>[];
    for (final m in active) {
      final store = await db.storesDao.findById(m.storeId);
      if (store != null) stores.add(store);
    }
    return stores;
  });
}
