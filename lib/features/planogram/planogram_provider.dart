import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import 'planogram_slot.dart';

part 'planogram_provider.g.dart';

// ---------------------------------------------------------------------------
// Stream providers
// ---------------------------------------------------------------------------

/// All planograms for the currently active store.
@riverpod
Stream<List<PlanogramsTableData>> planogramList(PlanogramListRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null || storeId.isEmpty) return Stream.value([]);
  return db.planogramsDao.watchByStore(storeId);
}

/// A single planogram by id, reactive to DB changes.
@riverpod
Stream<PlanogramsTableData?> planogramDetail(
  PlanogramDetailRef ref,
  String planogramId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.planogramsDao
      .watchAll()
      .map((list) => list.where((p) => p.id == planogramId).firstOrNull);
}

// ---------------------------------------------------------------------------
// Editor notifier — in-memory slot state bound to a single planogram id.
// ---------------------------------------------------------------------------

@riverpod
class PlanogramEditor extends _$PlanogramEditor {
  @override
  List<PgSlot> build(String planogramId) => const [];

  /// Initialize editor state from the planogram's stored slotsJson.
  /// Falls back to 6 empty default slots when the stored JSON is empty.
  void loadSlots(String slotsJson) {
    var slots = PgSlot.decodeList(slotsJson);
    if (slots.isEmpty) slots = PgSlot.defaults(6);
    state = slots;
  }

  /// Replace the product on a slot (by slot id).
  void assignProduct(
    String slotId,
    String productId,
    String name,
    String sku,
  ) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return s.copyWith(
        productId: productId,
        productName: name,
        productSku: sku,
      );
    }).toList();
  }

  /// Clear the product from a slot, leaving the slot frame in place.
  void clearSlot(String slotId) {
    state = state.map((s) {
      if (s.id != slotId) return s;
      return PgSlot(id: s.id, position: s.position);
    }).toList();
  }

  /// Persist the current editor state back to the planograms row.
  Future<void> save(String planogramId) async {
    final db = ref.read(appDatabaseProvider);
    final existing = await db.planogramsDao.findById(planogramId);
    if (existing == null) return;
    await db.planogramsDao.upsert(
      existing.toCompanion(true).copyWith(
            slotsJson: Value(PgSlot.encodeList(state)),
            updatedAt: Value(DateTime.now()),
          ),
    );
  }
}
