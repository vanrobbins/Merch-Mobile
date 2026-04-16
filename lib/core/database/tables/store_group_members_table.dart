import 'package:drift/drift.dart';

class StoreGroupMembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get storeId => text()();
  IntColumn get addedAt => integer()();
  TextColumn get addedByUid => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'store_group_members';
}
