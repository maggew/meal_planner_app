import 'package:drift/drift.dart';

class LocalMealPlanEntries extends Table {
  TextColumn get localId => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get groupId => text()();
  TextColumn get recipeId => text()();
  TextColumn get date => text()(); // 'yyyy-MM-dd'
  TextColumn get mealType => text()(); // 'breakfast' | 'lunch' | 'dinner'
  TextColumn get cookId => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingCreate'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
