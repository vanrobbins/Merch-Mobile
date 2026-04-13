import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/zones_table.dart';
import 'tables/fixtures_table.dart';
import 'tables/products_table.dart';
import 'tables/planograms_table.dart';
import 'tables/photo_docs_table.dart';
import 'daos/zones_dao.dart';
import 'daos/fixtures_dao.dart';
import 'daos/products_dao.dart';
import 'daos/planograms_dao.dart';
import 'daos/photo_docs_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ZonesTable, FixturesTable, ProductsTable, PlanogramsTable, PhotoDocsTable],
  daos: [ZonesDao, FixturesDao, ProductsDao, PlanogramsDao, PhotoDocsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'merch_mobile_db');
  }
}
