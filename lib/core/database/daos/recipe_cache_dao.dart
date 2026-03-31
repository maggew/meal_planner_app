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

  /// Returns a lightweight manifest of all cached recipes for delta-sync.
  Future<List<({String id, DateTime? updatedAt})>> getManifest(
    String groupId,
  ) async {
    final query = selectOnly(localRecipes)
      ..addColumns([localRecipes.id, localRecipes.updatedAt])
      ..where(localRecipes.groupId.equals(groupId))
      ..where(localRecipes.isDeleted.equals(false));
    final rows = await query.get();
    return rows
        .map((row) => (
              id: row.read(localRecipes.id)!,
              updatedAt: row.read(localRecipes.updatedAt),
            ))
        .toList();
  }

  /// Deletes recipes by a list of IDs (batch delete for removed recipes).
  Future<void> deleteByIds(List<String> ids) {
    return (delete(localRecipes)..where((t) => t.id.isIn(ids))).go();
  }

  /// Searches recipes by name (case-insensitive LIKE query).
  Future<List<LocalRecipe>> searchByName(String groupId, String query) {
    return (select(localRecipes)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Returns all non-deleted recipes for a group (no pagination).
  Future<List<LocalRecipe>> getAllByGroup(String groupId) {
    return (select(localRecipes)
          ..where((t) => t.groupId.equals(groupId))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
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
