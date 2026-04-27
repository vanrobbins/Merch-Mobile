import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/fixtures_dao.dart';
import '../../core/models/fixture.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';

part 'floor_builder_provider.g.dart';

const _uuid = Uuid();
const _sentinel = Object();

class FloorBuilderState {
  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final bool snapGridEnabled;
  final double gridSizeFt;
  final bool isDragging;
  final bool isLoading;
  final Map<String, PlanogramsTableData> planograms;

  const FloorBuilderState({
    this.fixtures = const [],
    this.selectedFixtureId,
    this.snapGridEnabled = true,
    this.gridSizeFt = 2.0,
    this.isDragging = false,
    this.isLoading = false,
    this.planograms = const {},
  });

  FloorBuilderState copyWith({
    List<Fixture>? fixtures,
    Object? selectedFixtureId = _sentinel,
    bool? snapGridEnabled,
    double? gridSizeFt,
    bool? isDragging,
    bool? isLoading,
    Map<String, PlanogramsTableData>? planograms,
  }) {
    return FloorBuilderState(
      fixtures: fixtures ?? this.fixtures,
      selectedFixtureId: selectedFixtureId == _sentinel
          ? this.selectedFixtureId
          : selectedFixtureId as String?,
      snapGridEnabled: snapGridEnabled ?? this.snapGridEnabled,
      gridSizeFt: gridSizeFt ?? this.gridSizeFt,
      isDragging: isDragging ?? this.isDragging,
      isLoading: isLoading ?? this.isLoading,
      planograms: planograms ?? this.planograms,
    );
  }
}

Fixture _rowToFixture(FixturesTableData r) => Fixture(
      id: r.id,
      zoneId: r.zoneId,
      fixtureType: r.fixtureType,
      posX: r.posX,
      posY: r.posY,
      rotation: r.rotation,
      widthFt: r.widthFt,
      depthFt: r.depthFt,
      label: r.label,
      planogramId: r.planogramId,
      planogramIdBack: r.planogramIdBack,
      wallAdjacent: r.wallAdjacent,
      updatedAt: r.updatedAt,
    );

FixturesTableCompanion _fixtureToCompanion(Fixture f) => FixturesTableCompanion(
      id: Value(f.id),
      zoneId: Value(f.zoneId),
      fixtureType: Value(f.fixtureType),
      posX: Value(f.posX),
      posY: Value(f.posY),
      rotation: Value(f.rotation),
      widthFt: Value(f.widthFt),
      depthFt: Value(f.depthFt),
      label: Value(f.label),
      planogramId: Value(f.planogramId),
      planogramIdBack: Value(f.planogramIdBack),
      wallAdjacent: Value(f.wallAdjacent),
      updatedAt: Value(f.updatedAt),
    );

@riverpod
class FloorBuilderNotifier extends _$FloorBuilderNotifier {
  StreamSubscription<List<FixturesTableData>>? _sub;
  StreamSubscription<List<PlanogramsTableData>>? _planogramSub;
  String? _zoneId;

  @override
  FloorBuilderState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _planogramSub?.cancel();
    });
    return const FloorBuilderState(isLoading: true);
  }

  FixturesDao get _dao => ref.read(appDatabaseProvider).fixturesDao;

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  /// Persists [fixture] for the active store.
  Future<void> _saveNew(Fixture fixture) {
    final companion = _fixtureToCompanion(fixture).copyWith(
      storeId: Value(_storeId),
    );
    return _dao.upsert(companion);
  }

  /// Looks up the fixture by [id], applies [mutate], and persists the result.
  Future<void> _updateFixture(String id, Fixture Function(Fixture) mutate) {
    final fixture = state.fixtures.firstWhere((f) => f.id == id);
    final updated = mutate(fixture).copyWith(updatedAt: DateTime.now());
    return _dao.upsert(_fixtureToCompanion(updated));
  }

  void loadFixtures(String zoneId) {
    _zoneId = zoneId;
    final storeId = _storeId;
    _sub?.cancel();
    _sub = _dao.watchByZone(storeId, zoneId).listen((rows) {
      state = state.copyWith(
        fixtures: rows.map(_rowToFixture).toList(),
        isLoading: false,
      );
    });
    _planogramSub?.cancel();
    _planogramSub = ref.read(appDatabaseProvider).planogramsDao.watchByStore(storeId).listen((rows) {
      state = state.copyWith(
        planograms: {for (final p in rows) p.id: p},
      );
    });
  }

  Future<void> addFixture(String type, Offset normalizedPos) async {
    if (_zoneId == null) return;
    await _saveNew(Fixture(
      id: _uuid.v4(),
      zoneId: _zoneId,
      fixtureType: type,
      posX: normalizedPos.dx,
      posY: normalizedPos.dy,
      label: type.toUpperCase(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> addWallFixture({
    required Offset centerFt,
    required double lengthFt,
    required double angleDeg,
  }) async {
    if (_zoneId == null) return;
    const depthFt = 0.5;
    await _saveNew(Fixture(
      id: _uuid.v4(),
      zoneId: _zoneId,
      fixtureType: 'wall',
      posX: centerFt.dx - lengthFt / 2,
      posY: centerFt.dy - depthFt / 2,
      rotation: angleDeg,
      widthFt: lengthFt,
      depthFt: depthFt,
      label: 'WALL',
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> moveFixture(String id, Offset pos) {
    double x = pos.dx;
    double y = pos.dy;
    if (state.snapGridEnabled) {
      final gs = state.gridSizeFt;
      x = (x / gs).round() * gs;
      y = (y / gs).round() * gs;
    }
    return _updateFixture(id, (f) => f.copyWith(posX: x, posY: y));
  }

  Future<void> rotateFixture(String id) =>
      _updateFixture(id, (f) => f.copyWith(rotation: (f.rotation + 90) % 360));

  Future<void> renameFixture(String id, String label) =>
      _updateFixture(id, (f) => f.copyWith(label: label));

  Future<void> deleteFixture(String id) async {
    await _dao.deleteById(id);
    if (state.selectedFixtureId == id) {
      state = state.copyWith(selectedFixtureId: null);
    }
  }

  void selectFixture(String? id) {
    state = state.copyWith(selectedFixtureId: id);
  }

  /// Clamps width/depth honoring per-type maxima (partitions max 1.0 ft depth).
  Fixture _resizedFixture(Fixture f, double? widthFt, double? depthFt) {
    final maxDepth = f.fixtureType == 'partition' ? 1.0 : double.infinity;
    return f.copyWith(
      widthFt: (widthFt ?? f.widthFt).clamp(0.5, double.infinity),
      depthFt: (depthFt ?? f.depthFt).clamp(0.5, maxDepth),
    );
  }

  void resizeFixtureLocal(String id, double? widthFt, double? depthFt) {
    final fixtures = state.fixtures
        .map((f) => f.id == id ? _resizedFixture(f, widthFt, depthFt) : f)
        .toList();
    state = state.copyWith(fixtures: fixtures);
  }

  Future<void> resizeFixture(String id, double? widthFt, double? depthFt) =>
      _updateFixture(id, (f) => _resizedFixture(f, widthFt, depthFt));

  Future<void> assignPlanogram(String fixtureId, String? planogramId) =>
      _updateFixture(fixtureId, (f) => f.copyWith(planogramId: planogramId));

  Future<void> assignPlanogramBack(String fixtureId, String? planogramId) =>
      _updateFixture(fixtureId, (f) => f.copyWith(planogramIdBack: planogramId));

  Future<void> toggleWallAdjacent(String fixtureId) {
    return _updateFixture(fixtureId, (f) {
      final newValue = !f.wallAdjacent;
      return f.copyWith(
        wallAdjacent: newValue,
        planogramIdBack: newValue ? null : f.planogramIdBack,
      );
    });
  }

  void toggleSnap() {
    state = state.copyWith(snapGridEnabled: !state.snapGridEnabled);
  }

  void setDragging(bool v) {
    state = state.copyWith(isDragging: v);
  }
}

@riverpod
Future<ZonesTableData?> zoneById(Ref ref, String zoneId) =>
    ref.watch(appDatabaseProvider).zonesDao.findById(zoneId);
