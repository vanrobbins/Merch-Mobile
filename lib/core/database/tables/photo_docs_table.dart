import 'package:drift/drift.dart';

class PhotoDocsTable extends Table {
  TextColumn get id => text()();
  TextColumn get fixtureId => text()();
  TextColumn get phase => text()(); // before/after
  TextColumn get localPath => text()();
  TextColumn get remoteUrl => text().withDefault(const Constant(''))();
  TextColumn get uploadStatus => text().withDefault(const Constant('pending'))(); // pending/uploaded/failed
  TextColumn get approvalStatus => text().withDefault(const Constant('pending'))(); // pending/approved/rejected
  TextColumn get planogramId => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get storeId => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
