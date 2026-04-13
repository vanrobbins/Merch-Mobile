import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/zones_table.dart';
import 'tables/fixtures_table.dart';
import 'tables/products_table.dart';
import 'tables/planograms_table.dart';
import 'tables/photo_docs_table.dart';
import 'tables/stores_table.dart';
import 'tables/store_memberships_table.dart';
import 'tables/store_groups_table.dart';
import 'tables/store_group_members_table.dart';
import 'tables/planogram_proposals_table.dart';
import 'daos/zones_dao.dart';
import 'daos/fixtures_dao.dart';
import 'daos/products_dao.dart';
import 'daos/planograms_dao.dart';
import 'daos/photo_docs_dao.dart';
import 'daos/stores_dao.dart';
import 'daos/store_memberships_dao.dart';
import 'daos/store_groups_dao.dart';
import 'daos/planogram_proposals_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ZonesTable,
    FixturesTable,
    ProductsTable,
    PlanogramsTable,
    PhotoDocsTable,
    StoresTable,
    StoreMembershipsTable,
    StoreGroupsTable,
    StoreGroupMembersTable,
    PlanogramProposalsTable,
  ],
  daos: [
    ZonesDao,
    FixturesDao,
    ProductsDao,
    PlanogramsDao,
    PhotoDocsDao,
    StoresDao,
    StoreMembershipsDao,
    StoreGroupsDao,
    PlanogramProposalsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  // Dev-only: wipe and recreate on schema change.
  // Production apps would use incremental migrations.
  @override
  MigrationStrategy get migration => destructiveFallback;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'merch_mobile_db');
  }
}
