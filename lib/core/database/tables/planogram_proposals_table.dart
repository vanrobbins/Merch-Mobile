import 'package:drift/drift.dart';

class PlanogramProposalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get planogramId => text()();
  TextColumn get storeId => text()();
  TextColumn get proposedByUid => text()();
  IntColumn get proposedAt => integer()();
  TextColumn get status => text()(); // pending | approved | rejected
  TextColumn get notes => text().nullable()();
  TextColumn get slotChanges => text().nullable()(); // JSON diff
  TextColumn get reviewedByUid => text().nullable()();
  IntColumn get reviewedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'planogram_proposals';
}
