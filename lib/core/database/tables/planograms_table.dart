import 'package:drift/drift.dart';

class PlanogramsTable extends Table {
  TextColumn get id => text()();
  TextColumn get fixtureId => text()();
  TextColumn get title => text()();
  TextColumn get season => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))(); // draft/published
  TextColumn get slotsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
