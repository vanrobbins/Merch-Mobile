import 'package:drift/drift.dart';

class StoreMembershipsTable extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get userUid => text()();
  TextColumn get role => text()(); // coordinator | manager | staff
  TextColumn get displayName => text()();
  TextColumn get status => text()(); // pending | active | rejected
  IntColumn get joinedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'store_memberships';
}
