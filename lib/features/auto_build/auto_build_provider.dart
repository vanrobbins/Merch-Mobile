import 'dart:convert';
import 'dart:math';

import 'dart:ui' show Offset;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/fixture.dart';
import '../../core/models/mannequin.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'auto_build_models.dart';

part 'auto_build_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AutoBuildState {
  final List<Fixture> currentFixtures;
  final List<Fixture> suggestedFixtures;
  final List<Mannequin> suggestedMannequins;
  final bool isComputing;
  final LayoutStyle layoutStyle;
  final LayoutDensity density;
  final bool includeMannequins;
  final String season;

  const AutoBuildState({
    this.currentFixtures = const [],
    this.suggestedFixtures = const [],
    this.suggestedMannequins = const [],
    this.isComputing = false,
    this.layoutStyle = LayoutStyle.mixed,
    this.density = LayoutDensity.medium,
    this.includeMannequins = false,
    this.season = 'Spring',
  });

  AutoBuildState copyWith({
    List<Fixture>? currentFixtures,
    List<Fixture>? suggestedFixtures,
    List<Mannequin>? suggestedMannequins,
    bool? isComputing,
    LayoutStyle? layoutStyle,
    LayoutDensity? density,
    bool? includeMannequins,
    String? season,
  }) {
    return AutoBuildState(
      currentFixtures: currentFixtures ?? this.currentFixtures,
      suggestedFixtures: suggestedFixtures ?? this.suggestedFixtures,
      suggestedMannequins: suggestedMannequins ?? this.suggestedMannequins,
      isComputing: isComputing ?? this.isComputing,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      density: density ?? this.density,
      includeMannequins: includeMannequins ?? this.includeMannequins,
      season: season ?? this.season,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class AutoBuildNotifier extends _$AutoBuildNotifier {
  @override
  AutoBuildState build() {
    return const AutoBuildState();
  }

  void setLayoutStyle(LayoutStyle style) =>
      state = state.copyWith(layoutStyle: style);

  void setDensity(LayoutDensity density) =>
      state = state.copyWith(density: density);

  void setIncludeMannequins(bool value) =>
      state = state.copyWith(includeMannequins: value);

  // -------------------------------------------------------------------------
  // computeAutoLayout
  //
  // Generates a suggested fixture layout for [zoneId] without persisting it.
  // Algorithm branches on layoutStyle and uses density for spacing.
  // -------------------------------------------------------------------------
  Future<void> computeAutoLayout(String zoneId, String season) async {
    state = state.copyWith(isComputing: true, season: season);
    try {
      final storeId = ref.read(activeStoreIdProvider).value ?? '';
      final spacing = state.density.spacingFt;

      // Load current fixtures
      final fixtureSnap = await FirestoreRefs.fixtures(storeId)
          .where('zoneId', isEqualTo: zoneId)
          .get();
      final current =
          fixtureSnap.docs.map(FixtureFirestore.fromDoc).toList();

      // Load zone for bounds
      final zoneSnap =
          await FirestoreRefs.zones(storeId).doc(zoneId).get();
      final StoreZone? zone =
          zoneSnap.exists ? StoreZoneFirestore.fromDoc(zoneSnap) : null;

      const double storeFtW = 40.0;
      const double storeFtH = 30.0;
      double zoneFtW = storeFtW * 0.4;
      double zoneFtH = storeFtH * 0.4;

      if (zone != null) {
        if (zone.shapePoints != null && zone.shapePoints!.isNotEmpty) {
          final pts = _parseShapePoints(zone.shapePoints!);
          if (pts.isNotEmpty) {
            final xs = pts.map((p) => p.dx).toList();
            final ys = pts.map((p) => p.dy).toList();
            zoneFtW = (xs.reduce(max) - xs.reduce(min)) * storeFtW;
            zoneFtH = (ys.reduce(max) - ys.reduce(min)) * storeFtH;
          }
        } else {
          zoneFtW = zone.width * storeFtW;
          zoneFtH = zone.height * storeFtH;
        }
      }

      const uuid = Uuid();
      final now = DateTime.now();
      final suggested = <Fixture>[];

      double nx(double ft) => (ft / zoneFtW).clamp(0.0, 1.0);
      double ny(double ft) => (ft / zoneFtH).clamp(0.0, 1.0);

      const double fixtureW = 4.0;
      const double fixtureD = 2.0;
      final int countAlongW =
          ((zoneFtW / spacing).floor()).clamp(1, 20);
      final int countAlongH =
          ((zoneFtH / spacing).floor()).clamp(1, 20);

      // Perimeter (wallHeavy or mixed)
      if (state.layoutStyle != LayoutStyle.centerGrid) {
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
      }

      // Center grid (mixed or centerGrid)
      if (state.layoutStyle != LayoutStyle.wallHeavy) {
        final gridCols =
            max(1, ((zoneFtW * 0.5) / (spacing * 2)).round());
        final gridRows =
            max(1, ((zoneFtH * 0.5) / (spacing * 2)).round());
        for (int r = 0; r < gridRows; r++) {
          for (int c = 0; c < gridCols; c++) {
            final xFrac = 0.25 + (c + 0.5) * (0.5 / gridCols);
            final yFrac = 0.25 + (r + 0.5) * (0.5 / gridRows);
            suggested.add(Fixture(
              id: uuid.v4(),
              zoneId: zoneId,
              fixtureType: 'table',
              posX: xFrac,
              posY: yFrac,
              rotation: 0.0,
              widthFt: 4.0,
              depthFt: 3.0,
              label: 'TABLE ${season.toUpperCase()}',
              updatedAt: now,
            ));
          }
        }
      }

      // Mannequins (when toggled on)
      final suggestedMannequins = <Mannequin>[];
      if (state.includeMannequins) {
        final count = switch (state.density) {
          LayoutDensity.low => 1,
          LayoutDensity.medium => 2,
          LayoutDensity.high => 3,
        };
        for (int i = 0; i < count; i++) {
          final xFrac = count == 1
              ? 0.5
              : 0.3 + i * (0.4 / (count - 1));
          suggestedMannequins.add(Mannequin(
            id: uuid.v4(),
            storeId: storeId,
            zoneId: zoneId,
            mannequinType: 'full_body',
            mountType: 'floor',
            positionX: xFrac.clamp(0.25, 0.75),
            positionY: 0.5,
            updatedAt: now,
          ));
        }
      }

      state = state.copyWith(
        currentFixtures: current,
        suggestedFixtures: suggested,
        suggestedMannequins: suggestedMannequins,
        isComputing: false,
      );
    } catch (_) {
      state = state.copyWith(isComputing: false);
      rethrow;
    }
  }

  /// Parse zone.shapePoints JSON — list of [x, y] normalized pairs.
  List<Offset> _parseShapePoints(String json) {
    if (json.isEmpty || json == '[]') return [];
    try {
      final raw = jsonDecode(json) as List;
      return raw.map((pt) {
        final pair = pt as List;
        return Offset(
          (pair[0] as num).toDouble(),
          (pair[1] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // applyAutoLayout — bulk-upsert suggestedFixtures + mannequins to Firestore
  // -------------------------------------------------------------------------
  Future<void> applyAutoLayout(String zoneId) async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final batch = FirebaseFirestore.instance.batch();
    for (final fixture in state.suggestedFixtures) {
      final docRef = FirestoreRefs.fixtures(storeId).doc(fixture.id);
      batch.set(docRef, fixture.toFirestore(), SetOptions(merge: true));
    }
    for (final mannequin in state.suggestedMannequins) {
      final docRef =
          FirestoreRefs.mannequins(storeId).doc(mannequin.id);
      batch.set(
          docRef, mannequin.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  // -------------------------------------------------------------------------
  // Firestore preset CRUD
  // -------------------------------------------------------------------------

  /// Save current control values as a named preset in Firestore.
  Future<void> saveAsPreset(String name) async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    const uuid = Uuid();
    final preset = AutoBuildPreset(
      id: uuid.v4(),
      name: name,
      season: state.season,
      layoutStyle: state.layoutStyle,
      density: state.density,
      includeMannequins: state.includeMannequins,
      createdByUid: uid,
      createdAt: DateTime.now(),
    );
    await FirestoreRefs.autoBuildPresets(storeId)
        .doc(preset.id)
        .set(preset.toFirestore());
  }

  /// Load a preset into state and recompute.
  Future<void> loadPreset(AutoBuildPreset preset, String zoneId) async {
    state = state.copyWith(
      layoutStyle: preset.layoutStyle,
      density: preset.density,
      includeMannequins: preset.includeMannequins,
    );
    await computeAutoLayout(zoneId, preset.season);
  }

  /// Delete a preset doc from Firestore.
  Future<void> deletePreset(String presetId) async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await FirestoreRefs.autoBuildPresets(storeId).doc(presetId).delete();
  }

  /// One-time fetch of all presets ordered newest first.
  Future<List<AutoBuildPreset>> fetchPresets() async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final snap = await FirestoreRefs.autoBuildPresets(storeId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AutoBuildPreset.fromDoc(
            d as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }
}
