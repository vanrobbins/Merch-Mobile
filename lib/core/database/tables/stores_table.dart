import 'package:drift/drift.dart';

class StoresTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get inviteCode => text().unique()();
  IntColumn get createdAt => integer()();
  TextColumn get ownerUid => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'stores';
}
