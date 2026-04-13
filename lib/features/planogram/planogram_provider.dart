import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/models/planogram.dart';
import '../../core/models/planogram_slot.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';

part 'planogram_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PlanogramState {
  final List<Planogram> planograms;
  final bool isLoading;

  const PlanogramState({
    required this.planograms,
    this.isLoading = false,
  });

  PlanogramState copyWith({
    List<Planogram>? planograms,
    bool? isLoading,
  }) =>
      PlanogramState(
        planograms: planograms ?? this.planograms,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ---------------------------------------------------------------------------
// Row ↔ model conversions
// ---------------------------------------------------------------------------

Planogram _rowToPlanogram(PlanogramsTableData r) {
  final rawSlots = jsonDecode(r.slotsJson) as List<dynamic>;
  final slots = rawSlots
      .map((e) => PlanogramSlot.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  return Planogram(
    id: r.id,
    fixtureId: r.fixtureId,
    title: r.title,
    season: r.season,
    status: r.status,
    slots: slots,
    publishedAt: r.publishedAt,
    updatedAt: r.updatedAt,
  );
}

PlanogramsTableCompanion _planogramToCompanion(Planogram p) =>
    PlanogramsTableCompanion(
      id: Value(p.id),
      fixtureId: Value(p.fixtureId),
      title: Value(p.title),
      season: Value(p.season),
      status: Value(p.status),
      slotsJson: Value(jsonEncode(p.slots.map((s) => s.toJson()).toList())),
      publishedAt: Value(p.publishedAt),
      updatedAt: Value(p.updatedAt),
    );

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class PlanogramNotifier extends _$PlanogramNotifier {
  StreamSubscription<List<PlanogramsTableData>>? _sub;

  @override
  PlanogramState build() {
    final db = ref.watch(appDatabaseProvider);
    _sub?.cancel();
    _sub = db.planogramsDao.watchAll().listen((rows) {
      state = state.copyWith(
        planograms: rows.map(_rowToPlanogram).toList(),
        isLoading: false,
      );
    });
    ref.onDispose(() => _sub?.cancel());
    return const PlanogramState(planograms: [], isLoading: true);
  }

  // -------------------------------------------------------------------------
  // Create
  // -------------------------------------------------------------------------

  Future<void> createPlanogram(
    String fixtureId,
    String title,
    String season,
  ) async {
    const uuid = Uuid();
    final planogram = Planogram(
      id: uuid.v4(),
      fixtureId: fixtureId,
      title: title,
      season: season,
      status: 'draft',
      slots: const [],
      updatedAt: DateTime.now(),
    );
    await ref
        .read(appDatabaseProvider)
        .planogramsDao
        .upsert(_planogramToCompanion(planogram));
  }

  // -------------------------------------------------------------------------
  // Slot helpers — each loads from current state and upserts
  // -------------------------------------------------------------------------

  Future<void> addSlot(String planogramId, PlanogramSlot slot) async {
    final planogram = _findById(planogramId);
    final updated = planogram.copyWith(
      slots: [...planogram.slots, slot],
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  Future<void> removeSlot(String planogramId, String slotId) async {
    final planogram = _findById(planogramId);
    final updated = planogram.copyWith(
      slots: planogram.slots.where((s) => s.id != slotId).toList(),
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  Future<void> setSlotProduct(
    String planogramId,
    String slotId,
    String productId,
  ) async {
    final planogram = _findById(planogramId);
    final updatedSlots = planogram.slots.map((s) {
      return s.id == slotId ? s.copyWith(productId: productId) : s;
    }).toList();
    final updated = planogram.copyWith(
      slots: updatedSlots,
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  Future<void> reorderSlots(
    String planogramId,
    int oldIndex,
    int newIndex,
  ) async {
    final planogram = _findById(planogramId);
    final slots = [...planogram.slots];

    // Adjust newIndex for removal offset
    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final slot = slots.removeAt(oldIndex);
    slots.insert(adjustedNew, slot);

    // Re-assign sequence numbers based on new order
    final resequenced = slots
        .asMap()
        .entries
        .map((e) => e.value.copyWith(sequence: e.key))
        .toList();

    final updated = planogram.copyWith(
      slots: resequenced,
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  // -------------------------------------------------------------------------
  // Status transitions (publish is coordinator-gated)
  // -------------------------------------------------------------------------

  Future<void> publish(String planogramId) async {
    final appUser = await ref.read(currentUserProvider.future);
    if (appUser == null || appUser.role != 'coordinator') {
      throw StateError('Only coordinators may publish a planogram.');
    }

    final planogram = _findById(planogramId);
    final updated = planogram.copyWith(
      status: 'published',
      publishedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  Future<void> retractToDraft(String planogramId) async {
    final planogram = _findById(planogramId);
    // publishedAt must be explicitly set to null; copyWith requires nullable override
    final updated = Planogram(
      id: planogram.id,
      fixtureId: planogram.fixtureId,
      title: planogram.title,
      season: planogram.season,
      status: 'draft',
      slots: planogram.slots,
      publishedAt: null,
      updatedAt: DateTime.now(),
    );
    await _upsert(updated);
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Planogram _findById(String planogramId) =>
      state.planograms.firstWhere((p) => p.id == planogramId);

  Future<void> _upsert(Planogram planogram) =>
      ref.read(appDatabaseProvider).planogramsDao.upsert(
            _planogramToCompanion(planogram),
          );
}
