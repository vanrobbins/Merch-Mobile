import 'dart:async';
import 'dart:ui';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/zones_table.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import 'zone_shape.dart';

part 'zone_map_provider.g.dart';

class ZoneMapState {
  final List<ZonesTableData> zones;
  final String? selectedZoneId;
  final bool isLoading;

  const ZoneMapState({
    required this.zones,
    this.selectedZoneId,
    this.isLoading = false,
  });

  ZoneMapState copyWith({
    List<ZonesTableData>? zones,
    Object? selectedZoneId = _sentinel,
    bool? isLoading,
  }) {
    return ZoneMapState(
      zones: zones ?? this.zones,
      selectedZoneId: selectedZoneId == _sentinel
          ? this.selectedZoneId
          : selectedZoneId as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _sentinel = Object();

@riverpod
class ZoneMapNotifier extends _$ZoneMapNotifier {
  StreamSubscription<List<ZonesTableData>>? _sub;

  @override
  ZoneMapState build() {
    final db = ref.watch(appDatabaseProvider);
    final storeIdAsync = ref.watch(activeStoreIdProvider);
    final storeId = storeIdAsync.value;

    _sub?.cancel();
    if (storeId != null && storeId.isNotEmpty) {
      _sub = db.zonesDao.watchByStore(storeId).listen((rows) {
        state = state.copyWith(zones: rows, isLoading: false);
      });
    }
    ref.onDispose(() => _sub?.cancel());

    return const ZoneMapState(zones: [], isLoading: true);
  }

  void selectZone(String? id) => state = state.copyWith(selectedZoneId: id);

  Future<void> addZone() async {
    final db = ref.read(appDatabaseProvider);
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final id = const Uuid().v4();
    const center = Offset(0.5, 0.5);
    await db.zonesDao.upsert(ZonesTableCompanion.insert(
      id: id,
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

  Future<void> updateZoneName(String id, String name) async {
    final db = ref.read(appDatabaseProvider);
    final zone = state.zones.firstWhere((z) => z.id == id);
    await db.zonesDao.upsert(zone.toCompanion(true).copyWith(
          name: Value(name),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> updateZoneColor(String id, int colorValue) async {
    final db = ref.read(appDatabaseProvider);
    final zone = state.zones.firstWhere((z) => z.id == id);
    await db.zonesDao.upsert(zone.toCompanion(true).copyWith(
          colorValue: Value(colorValue),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> updateZoneType(String id, String type) async {
    final db = ref.read(appDatabaseProvider);
    final zone = state.zones.firstWhere((z) => z.id == id);
    await db.zonesDao.upsert(zone.toCompanion(true).copyWith(
          zoneType: Value(type),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> updateZoneShape(String id, List<Offset> points) async {
    final db = ref.read(appDatabaseProvider);
    final zone = state.zones.firstWhere((z) => z.id == id);
    await db.zonesDao.upsert(zone.toCompanion(true).copyWith(
          shapePoints: Value(ZoneShape.encode(points)),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Updates zone shape in local state only (no DB write) — used for smooth vertex drag.
  void updateZoneShapeLocal(String id, List<Offset> points) {
    final updated = state.zones.map((z) {
      if (z.id != id) return z;
      return z.copyWith(shapePoints: Value(ZoneShape.encode(points)));
    }).toList();
    state = state.copyWith(zones: updated);
  }

  Future<void> deleteZone(String id) async {
    final db = ref.read(appDatabaseProvider);
    await db.zonesDao.deleteById(id);
    if (state.selectedZoneId == id) {
      state = state.copyWith(selectedZoneId: null);
    }
  }

  Future<void> applyPreset(String id, String presetName) async {
    final zone = state.zones.firstWhere((z) => z.id == id);
    final center = Offset(zone.posX, zone.posY);
    final points = ZoneShape.presetAt(presetName, center);
    await updateZoneShape(id, points);
  }
}
