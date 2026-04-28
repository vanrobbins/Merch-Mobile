import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/store.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import 'zone_shape.dart';

part 'zone_map_provider.g.dart';

const _sentinel = Object();

class ZoneMapState {
  final List<StoreZone> zones;
  final String? selectedZoneId;
  final bool isLoading;
  final Store? storeData;

  const ZoneMapState({
    required this.zones,
    this.selectedZoneId,
    this.isLoading = false,
    this.storeData,
  });

  ZoneMapState copyWith({
    List<StoreZone>? zones,
    Object? selectedZoneId = _sentinel,
    bool? isLoading,
    Object? storeData = _sentinel,
  }) {
    return ZoneMapState(
      zones: zones ?? this.zones,
      selectedZoneId: selectedZoneId == _sentinel
          ? this.selectedZoneId
          : selectedZoneId as String?,
      isLoading: isLoading ?? this.isLoading,
      storeData: storeData == _sentinel
          ? this.storeData
          : storeData as Store?,
    );
  }
}

@riverpod
class ZoneMapNotifier extends _$ZoneMapNotifier {
  StreamSubscription<List<StoreZone>>? _zoneSub;
  StreamSubscription<Store?>? _storeSub;

  @override
  ZoneMapState build() {
    final storeId = ref.watch(activeStoreIdProvider).value;

    _zoneSub?.cancel();
    _storeSub?.cancel();

    if (storeId != null && storeId.isNotEmpty) {
      _zoneSub = FirestoreRefs.zones(storeId)
          .snapshots()
          .map((s) => s.docs.map(StoreZoneFirestore.fromDoc).toList())
          .listen((rows) {
        state = state.copyWith(zones: rows, isLoading: false);
      });
      _storeSub = FirestoreRefs.store(storeId).snapshots().map(
        (s) => s.exists ? StoreFirestore.fromDoc(s) : null,
      ).listen((store) {
        state = state.copyWith(storeData: store);
      });
    }

    ref.onDispose(() {
      _zoneSub?.cancel();
      _storeSub?.cancel();
    });

    return const ZoneMapState(zones: [], isLoading: true);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  void selectZone(String? id) => state = state.copyWith(selectedZoneId: id);

  Future<void> addZone() async {
    const center = Offset(0.5, 0.5);
    final zone = StoreZone(
      id: const Uuid().v4(),
      name: 'Zone ${state.zones.length + 1}',
      colorValue: 0xFF3B6BC2,
      zoneType: 'display',
      shapePoints: ZoneShape.encode(ZoneShape.defaultRect(center)),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.zones(_storeId)
        .doc(zone.id)
        .set(zone.toFirestore());
  }

  Future<void> addZoneOfType(String zoneType) async {
    const center = Offset(0.5, 0.5);
    final name = zoneType == 'entrance'
        ? 'Entrance'
        : zoneType == 'cash_wrap'
            ? 'Cash Wrap'
            : 'Zone ${state.zones.length + 1}';
    final color = zoneType == 'entrance' ? 0xFF1A1917 : 0xFF3B6BC2;
    final zone = StoreZone(
      id: const Uuid().v4(),
      name: name,
      colorValue: color,
      zoneType: zoneType,
      shapePoints: ZoneShape.encode(ZoneShape.defaultRect(center)),
      updatedAt: DateTime.now(),
    );
    await FirestoreRefs.zones(_storeId)
        .doc(zone.id)
        .set(zone.toFirestore());
  }

  Future<void> updateZoneName(String id, String name) =>
      _patch(id, {'name': name});

  Future<void> updateZoneColor(String id, int colorValue) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(colorValue: colorValue) else z,
    ]);
    return _patch(id, {'colorValue': colorValue});
  }

  Future<void> updateZoneType(String id, String type) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(zoneType: type) else z,
    ]);
    return _patch(id, {'zoneType': type});
  }

  Future<void> updateZoneLocked(String id, {required bool locked}) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(positionLocked: locked) else z,
    ]);
    return _patch(id, {'positionLocked': locked});
  }

  Future<void> updateZoneShape(String id, List<Offset> points) =>
      _patch(id, {'shapePoints': ZoneShape.encode(points)});

  void updateZoneShapeLocal(String id, List<Offset> points) {
    state = state.copyWith(zones: [
      for (final z in state.zones)
        if (z.id == id)
          z.copyWith(shapePoints: ZoneShape.encode(points))
        else
          z,
    ]);
  }

  Future<void> moveZone(String id, Offset normDelta) =>
      updateZoneShape(id, _translatedPoints(id, normDelta));

  void moveZoneLocal(String id, Offset normDelta) =>
      updateZoneShapeLocal(id, _translatedPoints(id, normDelta));

  Future<void> addVertex(String id, int afterIdx, Offset normPt) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return Future.value();
    final pts = List.of(ZoneShape.decode(zone.shapePoints))
      ..insert(afterIdx + 1, normPt);
    return updateZoneShape(id, pts);
  }

  Future<void> removeVertex(String id, int idx) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return Future.value();
    final pts = List.of(ZoneShape.decode(zone.shapePoints));
    if (pts.length <= 3) return Future.value();
    pts.removeAt(idx);
    return updateZoneShape(id, pts);
  }

  Future<void> deleteZone(String id) async {
    await FirestoreRefs.zones(_storeId).doc(id).delete();
    if (state.selectedZoneId == id) {
      state = state.copyWith(selectedZoneId: null);
    }
  }

  Future<void> applyPreset(String id, String presetName) async {
    final zone = state.zones.firstWhere((z) => z.id == id);
    final points = ZoneShape.presetAt(presetName, Offset(zone.posX, zone.posY));
    await updateZoneShape(id, points);
  }

  Future<void> updateStoreDimensions(double widthFt, double depthFt) async {
    await FirestoreRefs.store(_storeId).update({
      'widthFt': widthFt,
      'depthFt': depthFt,
    });
  }

  Future<void> setEntrance(String entranceJson) async {
    for (final z in state.zones.where((z) => z.zoneType == 'entrance')) {
      await FirestoreRefs.zones(_storeId).doc(z.id).delete();
    }
    await FirestoreRefs.store(_storeId)
        .update({'entranceJson': entranceJson});
  }

  Future<void> removeEntrance() async {
    await FirestoreRefs.store(_storeId)
        .update({'entranceJson': FieldValue.delete()});
  }

  Future<void> _patch(String id, Map<String, dynamic> fields) async {
    await FirestoreRefs.zones(_storeId).doc(id).update({
      ...fields,
      'updatedAt': Timestamp.now(),
    });
  }

  List<Offset> _translatedPoints(String id, Offset normDelta) {
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return [];
    return [
      for (final p in ZoneShape.decode(zone.shapePoints))
        Offset(
          (p.dx + normDelta.dx).clamp(0.0, 1.0),
          (p.dy + normDelta.dy).clamp(0.0, 1.0),
        ),
    ];
  }
}
