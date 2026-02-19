import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalShoppingItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  ShoppingItemDao get shoppingItemDao => ShoppingItemDao(this);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meal_planner_db');
  }
}
