import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/models/fixture.dart';
import '../../core/providers/database_provider.dart';

part 'auto_build_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AutoBuildState {
  final List<Fixture> currentFixtures;
  final List<Fixture> suggestedFixtures;
  final bool isComputing;

  const AutoBuildState({
    this.currentFixtures = const [],
    this.suggestedFixtures = const [],
    this.isComputing = false,
  });

  AutoBuildState copyWith({
    List<Fixture>? currentFixtures,
    List<Fixture>? suggestedFixtures,
    bool? isComputing,
  }) {
    return AutoBuildState(
      currentFixtures: currentFixtures ?? this.currentFixtures,
      suggestedFixtures: suggestedFixtures ?? this.suggestedFixtures,
      isComputing: isComputing ?? this.isComputing,
    );
  }
}

// ---------------------------------------------------------------------------
// Row <-> Domain model helpers (same pattern as floor_builder_provider)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class AutoBuildNotifier extends _$AutoBuildNotifier {
  @override
  AutoBuildState build() {
    return const AutoBuildState();
  }

  // -------------------------------------------------------------------------
  // computeAutoLayout
  //
  // Generates a suggested fixture layout for [zoneId] without persisting it.
  // Algorithm:
  //   - Wall/shelf fixtures placed around the perimeter, ~2 ft apart
  //     (positions are normalized fractions of zone width/height)
  //   - Table fixtures placed in a center grid
  // -------------------------------------------------------------------------
  Future<void> computeAutoLayout(String zoneId, String season) async {
    state = state.copyWith(isComputing: true);

    try {
      final db = ref.read(appDatabaseProvider);

      // 1. Load current fixtures for this zone
      final currentRows =
          await db.fixturesDao.watchByParentId(zoneId).first;
      final current = currentRows.map(_rowToFixture).toList();

      // 2. Find the zone to get its bounds
      final allZoneRows = await db.zonesDao.watchAll().first;
      final ZonesTableData? zoneRow = allZoneRows.cast<ZonesTableData?>().firstWhere(
            (r) => r?.id == zoneId,
            orElse: () => null,
          );

      // Zone dimensions in feet — fall back to sensible defaults if zone
      // is not found. posX/posY/width/height are stored as normalized
      // fractions (0–1) relative to the canvas; we treat width/height as
      // proportional dimensions and scale to feet for the algorithm.
      // A typical retail floor spans ~40 ft × 30 ft.
      const double storeFtW = 40.0;
      const double storeFtH = 30.0;

      double zoneFtW = storeFtW * 0.4; // default ~40% of store width
      double zoneFtH = storeFtH * 0.4;

      if (zoneRow != null) {
        zoneFtW = zoneRow.width * storeFtW;
        zoneFtH = zoneRow.height * storeFtH;
      }

      // 3. Build suggested layout
      const uuid = Uuid();
      final now = DateTime.now();
      final suggested = <Fixture>[];

      // --- Perimeter wall/shelf fixtures (2 ft apart, normalized coords) ---
      const double spacing = 2.0; // feet between fixture centers
      const double fixtureW = 4.0; // fixture width ft
      const double fixtureD = 2.0; // fixture depth ft

      // How many fixtures fit along each wall edge (at least 1)
      final int countAlongW = ((zoneFtW / spacing).floor()).clamp(1, 20);
      final int countAlongH = ((zoneFtH / spacing).floor()).clamp(1, 20);

      // Normalize a foot position to 0-1 fraction within zone
      double nx(double ft) => (ft / zoneFtW).clamp(0.0, 1.0);
      double ny(double ft) => (ft / zoneFtH).clamp(0.0, 1.0);

      // Top wall — shelves (rotation 0)
      for (int i = 0; i < countAlongW; i++) {
        final x = (i + 0.5) * spacing;
        suggested.add(Fixture(
          id: uuid.v4(),
          zoneId: zoneId,
          fixtureType: 'shelf',
          posX: nx(x),
          posY: 0.02,
          rotation: 0.0,
          widthFt: fixtureW,
          depthFt: fixtureD,
          label: 'SHELF ${season.toUpperCase()}',
          updatedAt: now,
        ));
      }

      // Bottom wall — shelves (rotation 180)
      for (int i = 0; i < countAlongW; i++) {
        final x = (i + 0.5) * spacing;
        suggested.add(Fixture(
          id: uuid.v4(),
          zoneId: zoneId,
          fixtureType: 'shelf',
          posX: nx(x),
          posY: 0.96,
          rotation: 180.0,
          widthFt: fixtureW,
          depthFt: fixtureD,
          label: 'SHELF ${season.toUpperCase()}',
          updatedAt: now,
        ));
      }

      // Left wall — wall racks (rotation 270)
      for (int j = 0; j < countAlongH; j++) {
        final y = (j + 0.5) * spacing;
        suggested.add(Fixture(
          id: uuid.v4(),
          zoneId: zoneId,
          fixtureType: 'wall',
          posX: 0.02,
          posY: ny(y),
          rotation: 270.0,
          widthFt: fixtureW,
          depthFt: fixtureD,
          label: 'WALL ${season.toUpperCase()}',
          updatedAt: now,
        ));
      }

      // Right wall — wall racks (rotation 90)
      for (int j = 0; j < countAlongH; j++) {
        final y = (j + 0.5) * spacing;
        suggested.add(Fixture(
          id: uuid.v4(),
          zoneId: zoneId,
          fixtureType: 'wall',
          posX: 0.96,
          posY: ny(y),
          rotation: 90.0,
          widthFt: fixtureW,
          depthFt: fixtureD,
          label: 'WALL ${season.toUpperCase()}',
          updatedAt: now,
        ));
      }

      // --- Center grid — table fixtures ---
      // Use a 3×2 grid centered in the zone interior (0.25–0.75 range)
      const List<_GridPoint> centerGrid = [
        _GridPoint(0.33, 0.35),
        _GridPoint(0.50, 0.35),
        _GridPoint(0.67, 0.35),
        _GridPoint(0.33, 0.65),
        _GridPoint(0.50, 0.65),
        _GridPoint(0.67, 0.65),
      ];

      for (final pt in centerGrid) {
        suggested.add(Fixture(
          id: uuid.v4(),
          zoneId: zoneId,
          fixtureType: 'table',
          posX: pt.x,
          posY: pt.y,
          rotation: 0.0,
          widthFt: 4.0,
          depthFt: 3.0,
          label: 'TABLE ${season.toUpperCase()}',
          updatedAt: now,
        ));
      }

      state = state.copyWith(
        currentFixtures: current,
        suggestedFixtures: suggested,
        isComputing: false,
      );
    } catch (_) {
      state = state.copyWith(isComputing: false);
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // applyAutoLayout — bulk-upsert suggestedFixtures into the database
  // -------------------------------------------------------------------------
  Future<void> applyAutoLayout(String zoneId) async {
    final db = ref.read(appDatabaseProvider);
    for (final fixture in state.suggestedFixtures) {
      await db.fixturesDao.upsert(_fixtureToCompanion(fixture));
    }
  }

  // -------------------------------------------------------------------------
  // saveAsPreset — serialize suggestedFixtures to JSON in SharedPreferences
  // -------------------------------------------------------------------------
  Future<void> saveAsPreset(String name, String zoneId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.suggestedFixtures
        .map((f) => f.toJson())
        .toList();
    await prefs.setString('preset_$name', jsonEncode(jsonList));
  }

  // -------------------------------------------------------------------------
  // loadPreset — deserialize fixtures from SharedPreferences
  // -------------------------------------------------------------------------
  Future<void> loadPreset(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('preset_$name');
    if (raw == null) return;

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final fixtures = decoded
        .map((e) => Fixture.fromJson(e as Map<String, dynamic>))
        .toList();

    state = state.copyWith(suggestedFixtures: fixtures);
  }
}

// ---------------------------------------------------------------------------
// Small value type used in center-grid layout
// ---------------------------------------------------------------------------
class _GridPoint {
  final double x;
  final double y;
  const _GridPoint(this.x, this.y);
}
