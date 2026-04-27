import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import 'zone_shape.dart';

part 'zone_map_provider.g.dart';

const _sentinel = Object();

class ZoneMapState {
  final List<ZonesTableData> zones;
  final String? selectedZoneId;
  final bool isLoading;
  final StoresTableData? storeData;

  const ZoneMapState({
    required this.zones,
    this.selectedZoneId,
    this.isLoading = false,
    this.storeData,
  });

  ZoneMapState copyWith({
    List<ZonesTableData>? zones,
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
          : storeData as StoresTableData?,
    );
  }
}

@riverpod
class ZoneMapNotifier extends _$ZoneMapNotifier {
  StreamSubscription<List<ZonesTableData>>? _zoneSub;
  StreamSubscription<StoresTableData?>? _storeSub;

  @override
  ZoneMapState build() {
    final db = ref.watch(appDatabaseProvider);
    final storeId = ref.watch(activeStoreIdProvider).value;

    _zoneSub?.cancel();
    _storeSub?.cancel();
    if (storeId != null && storeId.isNotEmpty) {
      _zoneSub = db.zonesDao.watchByStore(storeId).listen((rows) {
        state = state.copyWith(zones: rows, isLoading: false);
      });
      _storeSub = db.storesDao.watchById(storeId).listen((store) {
        state = state.copyWith(storeData: store);
      });
    }
    ref.onDispose(() {
      _zoneSub?.cancel();
      _storeSub?.cancel();
    });

    return const ZoneMapState(zones: [], isLoading: true);
  }

  void selectZone(String? id) => state = state.copyWith(selectedZoneId: id);

  Future<void> addZone() async {
    final db = ref.read(appDatabaseProvider);
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    const center = Offset(0.5, 0.5);
    await db.zonesDao.upsert(ZonesTableCompanion.insert(
      id: const Uuid().v4(),
      name: 'Zone ${state.zones.length + 1}',
      colorValue: 0xFF3B6BC2,
      zoneType: 'display',
      storeId: storeId,
      posX: const Value(0.4),
      posY: const Value(0.4),
      width: const Value(0.2),
      height: const Value(0.15),
      shapePoints: Value(ZoneShape.encode(ZoneShape.defaultRect(center))),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> updateZoneName(String id, String name) =>
      _patchZone(id, (c) => c.copyWith(name: Value(name)));

  Future<void> updateZoneColor(String id, int colorValue) =>
      _patchZone(id, (c) => c.copyWith(colorValue: Value(colorValue)));

  Future<void> updateZoneType(String id, String type) =>
      _patchZone(id, (c) => c.copyWith(zoneType: Value(type)));

  Future<void> updateZoneShape(String id, List<Offset> points) =>
      _patchZone(id, (c) => c.copyWith(shapePoints: Value(ZoneShape.encode(points))));

  /// Updates zone shape in local state only — used for smooth vertex drag.
  void updateZoneShapeLocal(String id, List<Offset> points) {
    final encoded = ZoneShape.encode(points);
    final updated = [
      for (final z in state.zones)
        if (z.id == id) z.copyWith(shapePoints: Value(encoded)) else z,
    ];
    state = state.copyWith(zones: updated);
  }

  /// Translates all vertices of a zone by the given normalized delta, persists to DB.
  Future<void> moveZone(String id, Offset normDelta) =>
      updateZoneShape(id, _translatedPoints(id, normDelta));

  /// Translates all vertices in local state only — used for smooth drag preview.
  void moveZoneLocal(String id, Offset normDelta) =>
      updateZoneShapeLocal(id, _translatedPoints(id, normDelta));

  Future<void> deleteZone(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.zonesDao.deleteById(id);
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
    final db = ref.read(appDatabaseProvider);
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    await db.storesDao.updateDimensions(storeId, widthFt, depthFt);
  }

  // -- helpers --

  Future<void> _patchZone(
    String id,
    ZonesTableCompanion Function(ZonesTableCompanion) patch,
  ) async {
    final db = ref.read(appDatabaseProvider);
    final zone = state.zones.firstWhereOrNull((z) => z.id == id);
    if (zone == null) return;
    final companion = patch(zone.toCompanion(true))
        .copyWith(updatedAt: Value(DateTime.now()));
    await db.zonesDao.upsert(companion);
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
