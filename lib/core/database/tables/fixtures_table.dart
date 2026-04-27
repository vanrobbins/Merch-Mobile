import 'package:drift/drift.dart';

class FixturesTable extends Table {
  TextColumn get id => text()();
  TextColumn get zoneId => text().nullable()();
  TextColumn get fixtureType => text()(); // rack/table/shelf/wall/partition
  RealColumn get posX => real().withDefault(const Constant(0.0))();
  RealColumn get posY => real().withDefault(const Constant(0.0))();
  RealColumn get rotation => real().withDefault(const Constant(0.0))();
  RealColumn get widthFt => real().withDefault(const Constant(4.0))();
  RealColumn get depthFt => real().withDefault(const Constant(2.0))();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get storeId => text().withDefault(const Constant(''))();
  TextColumn get planogramId => text().nullable()();
  TextColumn get planogramIdBack => text().nullable()();
  BoolColumn get wallAdjacent => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
