import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/models/fixture.dart';
import '../../core/providers/database_provider.dart';

part 'floor_builder_provider.g.dart';

class FloorBuilderState {
  final List<Fixture> fixtures;
  final String? selectedFixtureId;
  final bool snapGridEnabled;
  final double gridSizeFt;
  final bool isDragging;
  final bool isLoading;

  const FloorBuilderState({
    this.fixtures = const [],
    this.selectedFixtureId,
    this.snapGridEnabled = true,
    this.gridSizeFt = 2.0,
    this.isDragging = false,
    this.isLoading = false,
  });

  FloorBuilderState copyWith({
    List<Fixture>? fixtures,
    Object? selectedFixtureId = _sentinel,
    bool? snapGridEnabled,
    double? gridSizeFt,
    bool? isDragging,
    bool? isLoading,
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
    );
  }
}

const _sentinel = Object();

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
      updatedAt: Value(f.updatedAt),
    );

@riverpod
class FloorBuilderNotifier extends _$FloorBuilderNotifier {
  StreamSubscription<List<FixturesTableData>>? _sub;
  String? _zoneId;

  @override
  FloorBuilderState build() {
    ref.onDispose(() => _sub?.cancel());
    return const FloorBuilderState(isLoading: true);
  }

  void loadFixtures(String zoneId) {
    _zoneId = zoneId;
    _sub?.cancel();
    final db = ref.read(appDatabaseProvider);
    _sub = db.fixturesDao.watchByParentId(zoneId).listen((rows) {
      state = state.copyWith(
        fixtures: rows.map(_rowToFixture).toList(),
        isLoading: false,
      );
    });
  }

  Future<void> addFixture(String type, Offset normalizedPos) async {
    if (_zoneId == null) return;
    const uuid = Uuid();
    final fixture = Fixture(
      id: uuid.v4(),
      zoneId: _zoneId!,
      fixtureType: type,
      posX: normalizedPos.dx,
      posY: normalizedPos.dy,
      rotation: 0.0,
      widthFt: 4.0,
      depthFt: 2.0,
      label: type.toUpperCase(),
      updatedAt: DateTime.now(),
    );
    await ref.read(appDatabaseProvider).fixturesDao.upsert(_fixtureToCompanion(fixture));
  }

  Future<void> moveFixture(String id, Offset pos) async {
    final fixture = state.fixtures.firstWhere((f) => f.id == id);
    double x = pos.dx;
    double y = pos.dy;
    if (state.snapGridEnabled) {
      final gs = state.gridSizeFt;
      x = (x / gs).round() * gs;
      y = (y / gs).round() * gs;
    }
    final updated = fixture.copyWith(posX: x, posY: y, updatedAt: DateTime.now());
    await ref.read(appDatabaseProvider).fixturesDao.upsert(_fixtureToCompanion(updated));
  }

  Future<void> rotateFixture(String id) async {
    final fixture = state.fixtures.firstWhere((f) => f.id == id);
    final newRotation = ((fixture.rotation + 90) % 360);
    final updated = fixture.copyWith(rotation: newRotation, updatedAt: DateTime.now());
    await ref.read(appDatabaseProvider).fixturesDao.upsert(_fixtureToCompanion(updated));
  }

  Future<void> renameFixture(String id, String label) async {
    final fixture = state.fixtures.firstWhere((f) => f.id == id);
    final updated = fixture.copyWith(label: label, updatedAt: DateTime.now());
    await ref.read(appDatabaseProvider).fixturesDao.upsert(_fixtureToCompanion(updated));
  }

  Future<void> deleteFixture(String id) async {
    await ref.read(appDatabaseProvider).fixturesDao.deleteById(id);
    if (state.selectedFixtureId == id) {
      state = state.copyWith(selectedFixtureId: null);
    }
  }

  void selectFixture(String? id) {
    state = state.copyWith(selectedFixtureId: id);
  }

  void toggleSnap() {
    state = state.copyWith(snapGridEnabled: !state.snapGridEnabled);
  }

  void setDragging(bool v) {
    state = state.copyWith(isDragging: v);
  }
}
