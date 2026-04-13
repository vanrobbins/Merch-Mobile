import 'package:drift/drift.dart';

class ZonesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer()();
  TextColumn get zoneType => text()();
  TextColumn get storeId => text()();
  RealColumn get posX => real().withDefault(const Constant(0.0))();
  RealColumn get posY => real().withDefault(const Constant(0.0))();
  RealColumn get width => real().withDefault(const Constant(0.2))();
  RealColumn get height => real().withDefault(const Constant(0.2))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
