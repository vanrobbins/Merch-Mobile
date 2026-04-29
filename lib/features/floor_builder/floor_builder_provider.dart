import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/fixture.dart';
import '../../core/models/mannequin.dart';
import '../../core/models/platform_element.dart';
import '../../core/models/planogram.dart';
import '../../core/models/scene_prop.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

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
  final Map<String, Planogram> planograms;
  final List<Mannequin> mannequins;
  final List<PlatformElement> platforms;
  final List<SceneProp> sceneProps;
  final bool isMultiSelectMode;
  final Set<String> selectedFixtureIds;

  const FloorBuilderState({
    this.fixtures = const [],
    this.selectedFixtureId,
    this.snapGridEnabled = true,
    this.gridSizeFt = 2.0,
    this.isDragging = false,
    this.isLoading = false,
    this.planograms = const {},
    this.mannequins = const [],
    this.platforms = const [],
    this.sceneProps = const [],
    this.isMultiSelectMode = false,
    this.selectedFixtureIds = const {},
  });

  FloorBuilderState copyWith({
    List<Fixture>? fixtures,
    Object? selectedFixtureId = _sentinel,
    bool? snapGridEnabled,
    double? gridSizeFt,
    bool? isDragging,
    bool? isLoading,
    Map<String, Planogram>? planograms,
    List<Mannequin>? mannequins,
    List<PlatformElement>? platforms,
    List<SceneProp>? sceneProps,
    bool? isMultiSelectMode,
    Set<String>? selectedFixtureIds,
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
      mannequins: mannequins ?? this.mannequins,
      platforms: platforms ?? this.platforms,
      sceneProps: sceneProps ?? this.sceneProps,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedFixtureIds: selectedFixtureIds ?? this.selectedFixtureIds,
    );
  }
}

@riverpod
class FloorBuilderNotifier extends _$FloorBuilderNotifier {
  StreamSubscription<List<Fixture>>? _sub;
  StreamSubscription<List<Planogram>>? _planogramSub;
  StreamSubscription<List<Mannequin>>? _mannequinSub;
  StreamSubscription<List<PlatformElement>>? _platformSub;
  StreamSubscription<List<SceneProp>>? _propSub;
  String? _zoneId;

  @override
  FloorBuilderState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _planogramSub?.cancel();
      _mannequinSub?.cancel();
      _platformSub?.cancel();
      _propSub?.cancel();
    });
    return const FloorBuilderState(isLoading: true);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  void loadFixtures(String zoneId) {
    _zoneId = zoneId;
    final storeId = _storeId;

    _sub?.cancel();
    _sub = FirestoreRefs.fixtures(storeId)
        .where('zoneId', isEqualTo: zoneId)
        .snapshots()
        .map((s) => s.docs.map(FixtureFirestore.fromDoc).toList())
        .listen((rows) {
      state = state.copyWith(fixtures: rows, isLoading: false);
    });

    _planogramSub?.cancel();
    _planogramSub = FirestoreRefs.planograms(storeId)
        .snapshots()
        .map((s) => s.docs.map(PlanogramFirestore.fromDoc).toList())
        .listen((rows) {
      state = state.copyWith(planograms: {for (final p in rows) p.id: p});
    });

    _mannequinSub?.cancel();
    _mannequinSub = FirestoreRefs.mannequins(storeId)
        .where('zoneId', isEqualTo: zoneId)
        .snapshots()
        .map((s) => s.docs.map(Mannequin.fromDoc).toList())
        .listen((rows) => state = state.copyWith(mannequins: rows));

    _platformSub?.cancel();
    _platformSub = FirestoreRefs.platforms(storeId)
        .where('zoneId', isEqualTo: zoneId)
        .snapshots()
        .map((s) => s.docs.map(PlatformElement.fromDoc).toList())
        .listen((rows) => state = state.copyWith(platforms: rows));

    _propSub?.cancel();
    _propSub = FirestoreRefs.sceneProps(storeId)
        .where('zoneId', isEqualTo: zoneId)
        .snapshots()
        .map((s) => s.docs.map(SceneProp.fromDoc).toList())
        .listen((rows) => state = state.copyWith(sceneProps: rows));
  }

  Future<void> addFixture(String type, Offset normalizedPos) async {
    if (_zoneId == null) return;
    final fixture = Fixture(
      id: _uuid.v4(),
      zoneId: _zoneId,
      fixtureType: type,
      posX: normalizedPos.dx,
      posY: normalizedPos.dy,
      label: type.toUpperCase(),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.fixtures(_storeId)
        .doc(fixture.id)
        .set(fixture.toFirestore());
  }

  Future<void> addWallFixture({
    required Offset centerFt,
    required double lengthFt,
    required double angleDeg,
  }) async {
    if (_zoneId == null) return;
    const depthFt = 0.5;
    final fixture = Fixture(
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
    );
    await FirestoreRefs.fixtures(_storeId)
        .doc(fixture.id)
        .set(fixture.toFirestore());
  }

  Future<void> moveFixture(String id, Offset pos) {
    double x = pos.dx;
    double y = pos.dy;
    if (state.snapGridEnabled) {
      final gs = state.gridSizeFt;
      x = (x / gs).round() * gs;
      y = (y / gs).round() * gs;
    }
    return _patch(id, {'posX': x, 'posY': y});
  }

  Future<void> rotateFixture(String id) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture == null) return Future.value();
    return _patch(id, {'rotation': (fixture.rotation + 90) % 360});
  }

  Future<void> renameFixture(String id, String label) =>
      _patch(id, {'label': label});

  Future<void> deleteFixture(String id) async {
    await FirestoreRefs.fixtures(_storeId).doc(id).delete();
    if (state.selectedFixtureId == id) {
      state = state.copyWith(selectedFixtureId: null);
    }
  }

  void selectFixture(String? id) => state = state.copyWith(selectedFixtureId: id);

  void enterMultiSelect(String fixtureId) {
    state = state.copyWith(
      isMultiSelectMode: true,
      selectedFixtureIds: {fixtureId},
      selectedFixtureId: null,
    );
  }

  void toggleMultiSelectFixture(String fixtureId) {
    final ids = Set<String>.from(state.selectedFixtureIds);
    if (ids.contains(fixtureId)) {
      ids.remove(fixtureId);
    } else {
      ids.add(fixtureId);
    }
    state = state.copyWith(
      isMultiSelectMode: ids.isNotEmpty,
      selectedFixtureIds: ids,
    );
  }

  void exitMultiSelect() {
    state = state.copyWith(
      isMultiSelectMode: false,
      selectedFixtureIds: const {},
    );
  }

  Future<void> deleteSelectedFixtures() async {
    final ids = state.selectedFixtureIds.toList();
    final storeId = _storeId;
    for (final id in ids) {
      await FirestoreRefs.fixtures(storeId).doc(id).delete();
    }
    state = state.copyWith(
      isMultiSelectMode: false,
      selectedFixtureIds: const {},
      selectedFixtureId: null,
    );
  }

  Fixture _resizedFixture(Fixture f, double? widthFt, double? depthFt) {
    final maxDepth = f.fixtureType == 'partition' ? 1.0 : double.infinity;
    return f.copyWith(
      widthFt: (widthFt ?? f.widthFt).clamp(0.5, double.infinity),
      depthFt: (depthFt ?? f.depthFt).clamp(0.5, maxDepth),
    );
  }

  void resizeFixtureLocal(String id, double? widthFt, double? depthFt) {
    state = state.copyWith(
      fixtures: state.fixtures
          .map((f) => f.id == id ? _resizedFixture(f, widthFt, depthFt) : f)
          .toList(),
    );
  }

  Future<void> resizeFixture(String id, double? widthFt, double? depthFt) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture == null) return Future.value();
    final updated = _resizedFixture(fixture, widthFt, depthFt);
    return _patch(id, {'widthFt': updated.widthFt, 'depthFt': updated.depthFt});
  }

  Future<void> assignPlanogram(String fixtureId, String? planogramId) =>
      _patch(fixtureId, {
        'planogramId': planogramId ?? FieldValue.delete(),
      });

  Future<void> assignPlanogramBack(String fixtureId, String? planogramId) =>
      _patch(fixtureId, {
        'planogramIdBack': planogramId ?? FieldValue.delete(),
      });

  Future<void> toggleWallAdjacent(String fixtureId) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == fixtureId);
    if (fixture == null) return Future.value();
    final newValue = !fixture.wallAdjacent;
    return _patch(fixtureId, {
      'wallAdjacent': newValue,
      if (newValue) 'planogramIdBack': FieldValue.delete(),
    });
  }

  void toggleSnap() => state = state.copyWith(snapGridEnabled: !state.snapGridEnabled);

  void setDragging(bool v) => state = state.copyWith(isDragging: v);

  Future<void> _patch(String id, Map<String, dynamic> fields) async {
    await FirestoreRefs.fixtures(_storeId).doc(id).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> addMannequin({
    required String mannequinType,
    required String mountType,
    required Offset positionFt,
  }) async {
    if (_zoneId == null) return;
    final storeId = _storeId;
    final mannequin = Mannequin(
      id: _uuid.v4(),
      storeId: storeId,
      zoneId: _zoneId!,
      mannequinType: mannequinType,
      mountType: mountType,
      positionX: positionFt.dx,
      positionY: positionFt.dy,
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.mannequins(storeId)
        .doc(mannequin.id)
        .set(mannequin.toFirestore());
  }

  Future<void> addPlatform({required Offset positionFt}) async {
    if (_zoneId == null) return;
    final storeId = _storeId;
    final platform = PlatformElement(
      id: _uuid.v4(),
      storeId: storeId,
      zoneId: _zoneId!,
      width: 4.0,
      depth: 4.0,
      elevation: 0.5,
      positionX: positionFt.dx,
      positionY: positionFt.dy,
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.platforms(storeId)
        .doc(platform.id)
        .set(platform.toFirestore());
  }

  Future<void> addSceneProp({required String propType, required Offset positionFt}) async {
    if (_zoneId == null) return;
    final storeId = _storeId;
    final prop = SceneProp(
      id: _uuid.v4(),
      storeId: storeId,
      zoneId: _zoneId!,
      propType: propType,
      name: propType.toUpperCase(),
      positionX: positionFt.dx,
      positionY: positionFt.dy,
      width: 2.0,
      depth: 2.0,
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.sceneProps(storeId)
        .doc(prop.id)
        .set(prop.toFirestore());
  }

  Future<void> deleteMannequin(String id) async {
    await FirestoreRefs.mannequins(_storeId).doc(id).delete();
  }

  Future<void> deletePlatform(String id) async {
    await FirestoreRefs.platforms(_storeId).doc(id).delete();
  }

  Future<void> deleteSceneProp(String id) async {
    await FirestoreRefs.sceneProps(_storeId).doc(id).delete();
  }
}

@riverpod
Stream<StoreZone?> zoneById(Ref ref, String zoneId) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value(null);
  return FirestoreRefs.zones(storeId).doc(zoneId).snapshots().map(
    (s) => s.exists ? StoreZoneFirestore.fromDoc(s) : null,
  );
}
