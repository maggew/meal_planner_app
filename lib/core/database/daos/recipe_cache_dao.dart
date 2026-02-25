import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/local_recipes_table.dart';

part 'recipe_cache_dao.g.dart';

@DriftAccessor(tables: [LocalRecipes])
class RecipeCacheDao extends DatabaseAccessor<AppDatabase>
    with _$RecipeCacheDaoMixin {
  RecipeCacheDao(super.db);

  // ==================== READ ====================

  Future<LocalRecipe?> getRecipeById(String recipeId) {
    return (select(localRecipes)..where((t) => t.id.equals(recipeId)))
        .getSingleOrNull();
  }

  Future<List<LocalRecipe>> getRecipesByGroup(
    String groupId, {
    required int limit,
    required int offset,
    required bool isDeleted,
  }) {
    return (select(localRecipes)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.isDeleted.equals(isDeleted))
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<LocalRecipe>> watchRecipesByGroup(String groupId) {
    return (select(localRecipes)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> countByGroup(String groupId) async {
    final count = countAll();
    final query = selectOnly(localRecipes)
      ..addColumns([count])
      ..where(localRecipes.groupId.equals(groupId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ==================== WRITE ====================

  Future<void> upsertRecipe(LocalRecipesCompanion companion) {
    return into(localRecipes).insertOnConflictUpdate(companion);
  }

  Future<void> replaceAllForGroup(
    String groupId,
    List<LocalRecipesCompanion> recipes,
  ) async {
    await transaction(() async {
      await (delete(localRecipes)
            ..where((t) => t.groupId.equals(groupId)))
          .go();

      await batch((b) {
        b.insertAll(localRecipes, recipes);
      });
    });
  }

  Future<void> deleteRecipe(String recipeId) {
    return (delete(localRecipes)..where((t) => t.id.equals(recipeId))).go();
  }

  Future<void> clearGroup(String groupId) {
    return (delete(localRecipes)..where((t) => t.groupId.equals(groupId))).go();
  }
}
