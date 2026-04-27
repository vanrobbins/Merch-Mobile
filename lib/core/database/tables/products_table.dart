import 'package:drift/drift.dart';

class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text().unique()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get sizesJson => text().withDefault(const Constant('[]'))();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  TextColumn get storeId => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
