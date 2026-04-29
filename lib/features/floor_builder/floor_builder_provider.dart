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
import 'undo_entry.dart';

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
  final bool canUndo;
  final bool canRedo;

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
    this.canUndo = false,
    this.canRedo = false,
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
    bool? canUndo,
    bool? canRedo,
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
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
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
  final List<UndoEntry> _undoStack = [];
  final List<UndoEntry> _redoStack = [];

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

  void _push(UndoEntry entry) {
    if (_undoStack.length >= 20) _undoStack.removeAt(0);
    _undoStack.add(entry);
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  CollectionReference<Map<String, dynamic>> _collectionRef(
      String storeId, String collection) {
    switch (collection) {
      case 'fixtures':
        return FirestoreRefs.fixtures(storeId);
      case 'mannequins':
        return FirestoreRefs.mannequins(storeId);
      case 'platforms':
        return FirestoreRefs.platforms(storeId);
      case 'sceneProps':
        return FirestoreRefs.sceneProps(storeId);
      default:
        throw ArgumentError('Unknown collection: $collection');
    }
  }

  Future<void> _applyEntry(
    List<Map<String, dynamic>?> values,
    List<String> ids,
    String collection,
  ) async {
    final storeId = _storeId;
    final coll = _collectionRef(storeId, collection);
    if (ids.length == 1) {
      final docRef = coll.doc(ids[0]);
      if (values[0] == null) {
        await docRef.delete();
      } else {
        await docRef.set({...values[0]!, 'updatedAt': Timestamp.now()});
      }
    } else {
      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < ids.length; i++) {
        final docRef = coll.doc(ids[i]);
        if (values[i] == null) {
          batch.delete(docRef);
        } else {
          batch.set(docRef, {...values[i]!, 'updatedAt': Timestamp.now()});
        }
      }
      await batch.commit();
    }
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final entry = _undoStack.removeLast();
    _redoStack.add(entry);
    state = state.copyWith(
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
    );
    await _applyEntry(entry.before, entry.ids, entry.collection);
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final entry = _redoStack.removeLast();
    _undoStack.add(entry);
    state = state.copyWith(
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
    );
    await _applyEntry(entry.after, entry.ids, entry.collection);
  }

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
    _push(UndoEntry(
      before: [null],
      after: [fixture.toFirestore()],
      ids: [fixture.id],
      collection: 'fixtures',
      label: 'Add fixture',
    ));
    await FirestoreRefs.fixtures(_storeId).doc(fixture.id).set(fixture.toFirestore());
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
    _push(UndoEntry(
      before: [null],
      after: [fixture.toFirestore()],
      ids: [fixture.id],
      collection: 'fixtures',
      label: 'Add wall fixture',
    ));
    await FirestoreRefs.fixtures(_storeId).doc(fixture.id).set(fixture.toFirestore());
  }

  Future<void> moveFixture(String id, Offset pos) {
    double x = pos.dx;
    double y = pos.dy;
    if (state.snapGridEnabled) {
      final gs = state.gridSizeFt;
      x = (x / gs).round() * gs;
      y = (y / gs).round() * gs;
    }
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture != null) {
      _push(UndoEntry(
        before: [fixture.toFirestore()],
        after: [{...fixture.toFirestore(), 'posX': x, 'posY': y}],
        ids: [id],
        collection: 'fixtures',
        label: 'Move fixture',
      ));
    }
    return _patch(id, {'posX': x, 'posY': y});
  }

  Future<void> rotateFixture(String id) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture == null) return Future.value();
    final newRot = (fixture.rotation + 90) % 360;
    _push(UndoEntry(
      before: [fixture.toFirestore()],
      after: [{...fixture.toFirestore(), 'rotation': newRot}],
      ids: [id],
      collection: 'fixtures',
      label: 'Rotate fixture',
    ));
    return _patch(id, {'rotation': newRot});
  }

  Future<void> renameFixture(String id, String label) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture != null) {
      _push(UndoEntry(
        before: [fixture.toFirestore()],
        after: [{...fixture.toFirestore(), 'label': label}],
        ids: [id],
        collection: 'fixtures',
        label: 'Rename fixture',
      ));
    }
    return _patch(id, {'label': label});
  }

  Future<void> deleteFixture(String id) async {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == id);
    if (fixture != null) {
      _push(UndoEntry(
        before: [fixture.toFirestore()],
        after: [null],
        ids: [id],
        collection: 'fixtures',
        label: 'Delete fixture',
      ));
    }
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
    final beforeMaps = ids
        .map((id) => state.fixtures.firstWhereOrNull((f) => f.id == id)?.toFirestore())
        .toList();
    _push(UndoEntry(
      before: beforeMaps,
      after: List.filled(ids.length, null),
      ids: ids,
      collection: 'fixtures',
      label: 'Delete ${ids.length} fixture${ids.length == 1 ? '' : 's'}',
    ));
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
    _push(UndoEntry(
      before: [fixture.toFirestore()],
      after: [updated.toFirestore()],
      ids: [id],
      collection: 'fixtures',
      label: 'Resize fixture',
    ));
    return _patch(id, {'widthFt': updated.widthFt, 'depthFt': updated.depthFt});
  }

  Future<void> assignPlanogram(String fixtureId, String? planogramId) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == fixtureId);
    if (fixture != null) {
      final after = fixture.copyWith(planogramId: planogramId).toFirestore();
      _push(UndoEntry(
        before: [fixture.toFirestore()],
        after: [after],
        ids: [fixtureId],
        collection: 'fixtures',
        label: planogramId != null ? 'Assign planogram' : 'Clear planogram',
      ));
    }
    return _patch(fixtureId, {
      'planogramId': planogramId ?? FieldValue.delete(),
    });
  }

  Future<void> assignPlanogramBack(String fixtureId, String? planogramId) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == fixtureId);
    if (fixture != null) {
      final after = fixture.copyWith(planogramIdBack: planogramId).toFirestore();
      _push(UndoEntry(
        before: [fixture.toFirestore()],
        after: [after],
        ids: [fixtureId],
        collection: 'fixtures',
        label: planogramId != null ? 'Assign back planogram' : 'Clear back planogram',
      ));
    }
    return _patch(fixtureId, {
      'planogramIdBack': planogramId ?? FieldValue.delete(),
    });
  }

  Future<void> toggleWallAdjacent(String fixtureId) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == fixtureId);
    if (fixture == null) return Future.value();
    final newValue = !fixture.wallAdjacent;
    final updated = newValue
        ? fixture.copyWith(wallAdjacent: true, planogramIdBack: null)
        : fixture.copyWith(wallAdjacent: false);
    _push(UndoEntry(
      before: [fixture.toFirestore()],
      after: [updated.toFirestore()],
      ids: [fixtureId],
      collection: 'fixtures',
      label: 'Toggle wall adjacent',
    ));
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
