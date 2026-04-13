import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/zones_table.dart';

part 'zones_dao.g.dart';

@DriftAccessor(tables: [ZonesTable])
class ZonesDao extends DatabaseAccessor<AppDatabase> with _$ZonesDaoMixin {
  ZonesDao(super.db);

  Stream<List<ZonesTableData>> watchAll() => select(zonesTable).watch();

  Stream<List<ZonesTableData>> watchByParentId(String storeId) =>
      (select(zonesTable)..where((t) => t.storeId.equals(storeId))).watch();

  Future<void> upsert(ZonesTableCompanion row) =>
      into(zonesTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(zonesTable)..where((t) => t.id.equals(id))).go();
}
