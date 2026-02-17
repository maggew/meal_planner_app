import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRecipeRemoteDatasource implements RecipeRemoteDatasource {
  final SupabaseClient supabase;

  SupabaseRecipeRemoteDatasource(this.supabase);

  @override
  Future<PostgrestMap?> getRecipeById(
      {required String recipeId, required String groupId}) async {
    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
          *,
          recipe_categories(categories(name)),
          recipe_ingredients(amount, unit, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeId, recipeId)
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .maybeSingle();

    return response;
  }

  @override
  Future<List<String>> getAllCategories() async {
    final response = await supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryName)
        .order(SupabaseConstants.categoryName);

    return (response as List)
        .map((data) => data[SupabaseConstants.categoryName] as String)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipesByCategory({
    required String category,
    required String groupId,
    required bool isDeleted,
    required int limit,
    required int offset,
    required RecipeSortOption sortOption,
  }) async {
    final baseQuery = supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
        *,
        recipe_categories!inner(categories!inner(name)),
        recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
      ''')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .eq('recipe_categories.categories.name', category.toLowerCase())
        .filter(
          SupabaseConstants.recipeDeletedAt,
          isDeleted ? 'not.is' : 'is',
          null,
        );

    final sortedQuery = switch (sortOption) {
      RecipeSortOption.alphabetical =>
        baseQuery.order(SupabaseConstants.recipeTitle, ascending: true),
      RecipeSortOption.newest =>
        baseQuery.order(SupabaseConstants.recipeCreatedAt, ascending: false),
      RecipeSortOption.oldest =>
        baseQuery.order(SupabaseConstants.recipeCreatedAt, ascending: true),
      RecipeSortOption.mostCooked =>
        baseQuery.order('times_cooked', ascending: false),
    };

    final response = await sortedQuery.range(offset, offset + limit - 1);

    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipesByCategories(
      {required List<String> categories, required String groupId}) async {
    final categoryResponse = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
          *,
          recipe_categories!inner(categories!inner(name)),
          recipe_ingredients(amount, unit, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .inFilter('recipe_categories.categories.name',
            categories.map((c) => c.toLowerCase()).toList())
        .order(SupabaseConstants.recipeCreatedAt, ascending: false);

    final ids =
        (categoryResponse as List).map((r) => r["id"] as String).toList();

    if (ids.isEmpty) return [];

    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
          *,
          recipe_categories(categories(name)),
          recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
        ''')
        .inFilter(SupabaseConstants.recipeId, ids)
        .order(SupabaseConstants.recipeCreatedAt, ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> deleteRecipeCategories(String recipeId) async {
    await supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .delete()
        .eq(SupabaseConstants.recipeCategoryRecipeId, recipeId);
  }

  @override
  Future<void> deleteRecipeIngredients(String recipeId) async {
    await supabase
        .from(SupabaseConstants.recipeIngredientsTable)
        .delete()
        .eq(SupabaseConstants.recipeIngredientRecipeId, recipeId);
  }

  @override
  Future<void> updateRecipe(
    String recipeId,
    Map<String, dynamic> data,
  ) async {
    await supabase
        .from(SupabaseConstants.recipesTable)
        .update(data)
        .eq(SupabaseConstants.recipeId, recipeId);
  }

  @override
  Future<void> insertRecipe({
    required String recipeId,
    required RecipeModel model,
    required String groupId,
    required String createdBy,
    String? imageUrl,
  }) async {
    await supabase.from(SupabaseConstants.recipesTable).insert(
          model.toSupabase(
            recipeId: recipeId,
            groupId: groupId,
            imageUrl: imageUrl,
            createdBy: createdBy,
          ),
        );
  }

  @override
  Future<void> saveRecipeCategories(
      {required String recipeId, required List<String> categories}) async {
    for (final categoryName in categories) {
      try {
        final categoryId = await upsertCategory(name: categoryName);
        await supabase.from(SupabaseConstants.recipeCategoriesTable).insert({
          SupabaseConstants.recipeCategoryRecipeId: recipeId,
          SupabaseConstants.recipeCategoryCategoryId: categoryId,
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<String> upsertCategory({required String name}) async {
    final existing = await supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .eq(SupabaseConstants.categoryName, name.toLowerCase())
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.categoryId] as String;
    }

    final categoryId = generateUuid();

    await supabase.from(SupabaseConstants.categoriesTable).insert({
      SupabaseConstants.categoryId: categoryId,
      SupabaseConstants.categoryName: name.toLowerCase(),
    });

    return categoryId;
  }

  @override
  Future<void> saveRecipeIngredients({
    required String recipeId,
    required List<IngredientModel> ingredients,
  }) async {
    for (final ingredient in ingredients) {
      final ingredientId = await upsertIngredient(name: ingredient.name);

      await supabase.from(SupabaseConstants.recipeIngredientsTable).insert(
            ingredient.toSupabaseRecipeIngredient(
              recipeId,
              ingredientId,
            ),
          );
    }
  }

  @override
  Future<String> upsertIngredient({required String name}) async {
    final existing = await supabase
        .from(SupabaseConstants.ingredientsTable)
        .select(SupabaseConstants.ingredientId)
        .eq(SupabaseConstants.ingredientName, name)
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.ingredientId] as String;
    }

    final ingredientId = generateUuid();
    await supabase.from(SupabaseConstants.ingredientsTable).insert({
      SupabaseConstants.ingredientId: ingredientId,
      SupabaseConstants.ingredientName: name,
    });

    return ingredientId;
  }

  @override
  Future<void> hardDeleteRecipe(String recipeId) {
    return supabase
        .from(SupabaseConstants.recipesTable)
        .delete()
        .eq(SupabaseConstants.recipeId, recipeId);
  }

  @override
  Future<void> restoreRecipe(String recipeId) {
    return supabase
        .from(SupabaseConstants.recipesTable)
        .update({SupabaseConstants.recipeDeletedAt: null}).eq(
            SupabaseConstants.recipeId, recipeId);
  }

  @override
  Future<void> softDeleteRecipe(String recipeId) {
    return supabase.from(SupabaseConstants.recipesTable).update({
      SupabaseConstants.recipeDeletedAt: DateTime.now().toIso8601String()
    }).eq(SupabaseConstants.recipeId, recipeId);
  }

  // Timer
  @override
  Future<List<Map<String, dynamic>>> getTimersForRecipe(String recipeId) async {
    final response = await supabase
        .from(SupabaseConstants.recipeTimersTable)
        .select()
        .eq(SupabaseConstants.recipeTimerRecipeId, recipeId);

    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> upsertTimer(Map<String, dynamic> data) async {
    final response = await supabase
        .from(SupabaseConstants.recipeTimersTable)
        .upsert(
          data,
          onConflict: '${SupabaseConstants.recipeTimerRecipeId},'
              '${SupabaseConstants.recipeTimerStepIndex}',
        )
        .select()
        .single();

    return response;
  }

  @override
  Future<void> deleteTimer(String recipeId, int stepIndex) async {
    await supabase
        .from(SupabaseConstants.recipeTimersTable)
        .delete()
        .eq(SupabaseConstants.recipeTimerRecipeId, recipeId)
        .eq(SupabaseConstants.recipeTimerStepIndex, stepIndex);
  }
}
