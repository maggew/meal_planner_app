import 'package:drift/drift.dart';

class LocalMealPlanEntries extends Table {
  TextColumn get localId => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get groupId => text()();
  TextColumn get recipeId => text()(); // '' for custom (free-text) entries
  TextColumn get customName => text().nullable()();
  TextColumn get date => text()(); // 'yyyy-MM-dd'
  TextColumn get mealType => text()(); // 'breakfast' | 'lunch' | 'dinner'
  TextColumn get cookIdsJson => text().nullable()(); // JSON array of cook IDs
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingCreate'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
