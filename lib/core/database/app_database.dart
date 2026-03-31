import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/core/database/daos/shopping_item_dao.dart';
import 'package:meal_planner/core/database/tables/local_meal_plan_entries_table.dart';
import 'package:meal_planner/core/database/tables/local_recipes_table.dart';
import 'package:meal_planner/core/database/tables/local_shopping_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalShoppingItems, LocalRecipes, LocalMealPlanEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(localRecipes);
          }
          if (from < 3) {
            await migrator.createTable(localMealPlanEntries);
          }
          if (from < 6) {
            await migrator.addColumn(
                localRecipes, localRecipes.carbTagsJson);
          }
          if (from < 7) {
            // Recreate table: cookId removed, cookIdsJson added.
            // Local data is lost but will be re-pulled from Supabase.
            await migrator.drop(localMealPlanEntries);
            await migrator.createTable(localMealPlanEntries);
          }
          if (from < 8) {
            await migrator.addColumn(
                localRecipes, localRecipes.updatedAt);
          }
        },
      );

  ShoppingItemDao get shoppingItemDao => ShoppingItemDao(this);
  RecipeCacheDao get recipeCacheDao => RecipeCacheDao(this);
  MealPlanDao get mealPlanDao => MealPlanDao(this);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meal_planner_db');
  }
}
