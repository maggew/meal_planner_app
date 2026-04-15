import 'package:drift/drift.dart';

class LocalRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get name => text()();
  IntColumn get portions => integer()();
  TextColumn get instructions => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get categoriesJson => text()();
  TextColumn get ingredientSectionsJson => text()();
  TextColumn get timersJson => text()();
  TextColumn get carbTagsJson => text().withDefault(const Constant('[]'))();
  IntColumn get timesCooked => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
