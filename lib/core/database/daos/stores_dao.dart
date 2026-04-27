import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/stores_table.dart';

part 'stores_dao.g.dart';

@DriftAccessor(tables: [StoresTable])
class StoresDao extends DatabaseAccessor<AppDatabase> with _$StoresDaoMixin {
  StoresDao(super.db);

  Stream<List<StoresTableData>> watchAll() => select(storesTable).watch();

  Stream<StoresTableData?> watchById(String id) =>
      (select(storesTable)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<StoresTableData?> findById(String id) =>
      (select(storesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<StoresTableData?> findByInviteCode(String code) =>
      (select(storesTable)..where((t) => t.inviteCode.equals(code))).getSingleOrNull();

  Future<void> upsert(StoresTableCompanion row) =>
      into(storesTable).insertOnConflictUpdate(row);

  Future<void> updateDimensions(String id, double widthFt, double depthFt) =>
      (update(storesTable)..where((t) => t.id.equals(id))).write(
        StoresTableCompanion(
          widthFt: Value(widthFt),
          depthFt: Value(depthFt),
        ),
      );

  Future<void> deleteById(String id) =>
      (delete(storesTable)..where((t) => t.id.equals(id))).go();
}
