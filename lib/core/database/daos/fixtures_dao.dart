import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/fixtures_table.dart';

part 'fixtures_dao.g.dart';

@DriftAccessor(tables: [FixturesTable])
class FixturesDao extends DatabaseAccessor<AppDatabase> with _$FixturesDaoMixin {
  FixturesDao(super.db);

  Stream<List<FixturesTableData>> watchAll() => select(fixturesTable).watch();

  /// Primary query: fixtures for a specific zone within a store.
  Stream<List<FixturesTableData>> watchByZone(String storeId, String zoneId) =>
      (select(fixturesTable)
            ..where((t) => t.storeId.equals(storeId) & t.zoneId.equals(zoneId)))
          .watch();

  /// Legacy alias (zoneId only) — used by ZoneDetailScreen.
  Stream<List<FixturesTableData>> watchByParentId(String zoneId) =>
      (select(fixturesTable)..where((t) => t.zoneId.equals(zoneId))).watch();

  Future<void> upsert(FixturesTableCompanion row) =>
      into(fixturesTable).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(fixturesTable)..where((t) => t.id.equals(id))).go();
}
