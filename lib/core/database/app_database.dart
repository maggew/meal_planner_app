import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/core/database/tables/local_recipes_table.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalShoppingItems, LocalRecipes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(localRecipes);
          }
        },
      );

  ShoppingItemDao get shoppingItemDao => ShoppingItemDao(this);
  RecipeCacheDao get recipeCacheDao => RecipeCacheDao(this);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meal_planner_db');
  }
}
