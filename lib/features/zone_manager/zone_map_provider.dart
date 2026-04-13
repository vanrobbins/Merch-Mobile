import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/app_theme.dart';

part 'zone_map_provider.g.dart';

class ZoneMapState {
  final List<StoreZone> zones;
  final String? selectedZoneId;
  final bool isLoading;

  const ZoneMapState({
    required this.zones,
    this.selectedZoneId,
    this.isLoading = false,
  });

  ZoneMapState copyWith({
    List<StoreZone>? zones,
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

// Converts a Drift table row to a domain model
StoreZone _rowToZone(ZonesTableData row) => StoreZone(
      id: row.id,
      name: row.name,
      colorValue: row.colorValue,
      zoneType: row.zoneType,
      storeId: row.storeId,
      posX: row.posX,
      posY: row.posY,
      width: row.width,
      height: row.height,
      updatedAt: row.updatedAt,
    );

// Converts a domain model to a Drift companion for upsert
ZonesTableCompanion _zoneToCompanion(StoreZone z) => ZonesTableCompanion(
      id: Value(z.id),
      name: Value(z.name),
      colorValue: Value(z.colorValue),
      zoneType: Value(z.zoneType),
      storeId: Value(z.storeId),
      posX: Value(z.posX),
      posY: Value(z.posY),
      width: Value(z.width),
      height: Value(z.height),
      updatedAt: Value(z.updatedAt),
    );

@riverpod
class ZoneMapNotifier extends _$ZoneMapNotifier {
  StreamSubscription<List<ZonesTableData>>? _sub;

  @override
  ZoneMapState build() {
    final db = ref.watch(appDatabaseProvider);
    _sub?.cancel();
    _sub = db.zonesDao.watchAll().listen((rows) {
      state = state.copyWith(
        zones: rows.map(_rowToZone).toList(),
        isLoading: false,
      );
    });
    ref.onDispose(() => _sub?.cancel());
    return const ZoneMapState(zones: [], isLoading: true);
  }

  Future<void> createDefaultZones() async {
    if (state.zones.isNotEmpty) return;
    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();

    final defaults = [
      _makeZone(uuid, 'WOMENS', 'womens', 0.05, 0.05, 0.4, 0.4, now),
      _makeZone(uuid, 'MENS', 'mens', 0.55, 0.05, 0.4, 0.4, now),
      _makeZone(uuid, 'ACCESSORIES', 'accessories', 0.05, 0.55, 0.25, 0.35, now),
      _makeZone(uuid, 'FITTING', 'fitting', 0.35, 0.55, 0.3, 0.35, now),
      _makeZone(uuid, 'ENTRANCE', 'entrance', 0.7, 0.55, 0.25, 0.35, now),
    ];

    for (final zone in defaults) {
      await db.zonesDao.upsert(_zoneToCompanion(zone));
    }
  }

  StoreZone _makeZone(
    Uuid uuid,
    String name,
    String type,
    double x,
    double y,
    double w,
    double h,
    DateTime now,
  ) {
    final color = AppTheme.zoneColors[type] ?? AppTheme.accent;
    return StoreZone(
      id: uuid.v4(),
      name: name,
      colorValue: color.toARGB32(),
      zoneType: type,
      storeId: 'default',
      posX: x,
      posY: y,
      width: w,
      height: h,
      updatedAt: now,
    );
  }

  void selectZone(String? id) {
    state = state.copyWith(selectedZoneId: id);
  }

  Future<void> updateZoneName(String id, String name) async {
    final zone = state.zones.firstWhere((z) => z.id == id);
    final updated = zone.copyWith(name: name, updatedAt: DateTime.now());
    await ref.read(appDatabaseProvider).zonesDao.upsert(_zoneToCompanion(updated));
  }

  Future<void> updateZoneColor(String id, int colorValue) async {
    final zone = state.zones.firstWhere((z) => z.id == id);
    final updated = zone.copyWith(colorValue: colorValue, updatedAt: DateTime.now());
    await ref.read(appDatabaseProvider).zonesDao.upsert(_zoneToCompanion(updated));
  }

  Future<void> addZone() async {
    const uuid = Uuid();
    final zone = StoreZone(
      id: uuid.v4(),
      name: 'NEW ZONE',
      colorValue: AppTheme.accent.toARGB32(),
      zoneType: 'custom',
      storeId: 'default',
      posX: 0.1,
      posY: 0.1,
      width: 0.2,
      height: 0.2,
      updatedAt: DateTime.now(),
    );
    await ref.read(appDatabaseProvider).zonesDao.upsert(_zoneToCompanion(zone));
  }
}
