import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/zones_table.dart';

part 'zones_dao.g.dart';

@DriftAccessor(tables: [ZonesTable])
class ZonesDao extends DatabaseAccessor<AppDatabase> with _$ZonesDaoMixin {
  ZonesDao(super.db);

  Stream<List<ZonesTableData>> watchAll() => select(zonesTable).watch();

  /// Watch all zones for a store (primary query for zone map).
  Stream<List<ZonesTableData>> watchByStore(String storeId) =>
      (select(zonesTable)..where((t) => t.storeId.equals(storeId))).watch();

  /// Legacy alias used by some providers.
  Stream<List<ZonesTableData>> watchByParentId(String storeId) =>
      watchByStore(storeId);

  Future<ZonesTableData?> findById(String id) =>
      (select(zonesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(ZonesTableCompanion row) =>
      into(zonesTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(zonesTable)..where((t) => t.id.equals(id))).go();
}
