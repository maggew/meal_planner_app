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
          recipe_categories(categories(id, name)),
          recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeId, recipeId)
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .maybeSingle();

    return response;
  }

  @override
  Future<List<String>> getAllCategories({required String groupId}) async {
    final response = await supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryName)
        .eq(SupabaseConstants.categoryGroupId, groupId)
        .order(SupabaseConstants.categorySortOrder, ascending: true);

    return (response as List)
        .map((data) => data[SupabaseConstants.categoryName] as String)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipesByCategoryId({
    required String categoryId,
    required String groupId,
    required bool isDeleted,
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
        .eq('recipe_categories.category_id', categoryId)
        .filter(
          SupabaseConstants.recipeDeletedAt,
          isDeleted ? 'not.is' : 'is',
          null,
        );

    final response = await switch (sortOption) {
      RecipeSortOption.alphabetical =>
        baseQuery.order(SupabaseConstants.recipeTitle, ascending: true),
      RecipeSortOption.newest =>
        baseQuery.order(SupabaseConstants.recipeCreatedAt, ascending: false),
      RecipeSortOption.oldest =>
        baseQuery.order(SupabaseConstants.recipeCreatedAt, ascending: true),
      RecipeSortOption.mostCooked =>
        baseQuery.order('times_cooked', ascending: false),
    };

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
          recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .inFilter('recipe_categories.categories.name', categories)
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
  Future<List<Map<String, dynamic>>> getDeletedRecipes({
    required String groupId,
    required int offset,
    required int limit,
  }) async {
    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
          *,
          recipe_categories(categories(name)),
          recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .filter(SupabaseConstants.recipeDeletedAt, 'not.is', null)
        .order(SupabaseConstants.recipeDeletedAt, ascending: false)
        .range(offset, offset + limit - 1);

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
  Future<void> saveRecipeCategories({
    required String recipeId,
    required List<String> categories,
    required String groupId,
  }) async {
    if (categories.isEmpty) return;

    // 1. Alle bestehenden Kategorien in einer Query laden
    final existing = await supabase
        .from(SupabaseConstants.categoriesTable)
        .select('${SupabaseConstants.categoryId}, ${SupabaseConstants.categoryName}')
        .eq(SupabaseConstants.categoryGroupId, groupId)
        .inFilter(SupabaseConstants.categoryName, categories);

    final idMap = {
      for (final row in existing as List)
        row[SupabaseConstants.categoryName] as String:
            row[SupabaseConstants.categoryId] as String,
    };

    // 2. Fehlende Kategorien einzeln anlegen (Sonderfall, sollte normalerweise nicht vorkommen)
    for (final name in categories) {
      if (!idMap.containsKey(name)) {
        idMap[name] = await upsertCategory(name: name, groupId: groupId);
      }
    }

    // 3. Alle recipe_category-Einträge in einem Batch einfügen
    await supabase.from(SupabaseConstants.recipeCategoriesTable).insert([
      for (final name in categories)
        {
          SupabaseConstants.recipeCategoryRecipeId: recipeId,
          SupabaseConstants.recipeCategoryCategoryId: idMap[name]!,
        },
    ]);
  }

  @override
  Future<String> upsertCategory({
    required String name,
    required String groupId,
  }) async {
    final existing = await supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .eq(SupabaseConstants.categoryName, name)
        .eq(SupabaseConstants.categoryGroupId, groupId)
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.categoryId] as String;
    }

    final categoryId = generateUuid();

    await supabase.from(SupabaseConstants.categoriesTable).insert({
      SupabaseConstants.categoryId: categoryId,
      SupabaseConstants.categoryName: name,
      SupabaseConstants.categoryGroupId: groupId,
    });

    return categoryId;
  }

  @override
  Future<void> saveRecipeIngredients({
    required String recipeId,
    required List<IngredientModel> ingredients,
  }) async {
    if (ingredients.isEmpty) return;

    final names = ingredients.map((i) => i.name).toList();

    // 1. Alle bestehenden Zutaten in einer Query laden
    final existing = await supabase
        .from(SupabaseConstants.ingredientsTable)
        .select('${SupabaseConstants.ingredientId}, ${SupabaseConstants.ingredientName}')
        .inFilter(SupabaseConstants.ingredientName, names);

    final idMap = {
      for (final row in existing as List)
        row[SupabaseConstants.ingredientName] as String:
            row[SupabaseConstants.ingredientId] as String,
    };

    // 2. Neue Zutaten in einem Batch anlegen (dedupliziert)
    final seenNames = <String>{...idMap.keys};
    final newRows = <Map<String, String>>[];
    for (final ingredient in ingredients) {
      if (seenNames.add(ingredient.name)) {
        newRows.add({
          SupabaseConstants.ingredientId: generateUuid(),
          SupabaseConstants.ingredientName: ingredient.name,
        });
      }
    }

    if (newRows.isNotEmpty) {
      await supabase.from(SupabaseConstants.ingredientsTable).upsert(
        newRows,
        onConflict: SupabaseConstants.ingredientName,
        ignoreDuplicates: true,
      );
      // IDs der tatsächlich eingefügten/existierenden Zutaten nachladen
      final newNames = newRows.map((r) => r[SupabaseConstants.ingredientName]!).toList();
      final inserted = await supabase
          .from(SupabaseConstants.ingredientsTable)
          .select('${SupabaseConstants.ingredientId}, ${SupabaseConstants.ingredientName}')
          .inFilter(SupabaseConstants.ingredientName, newNames);
      for (final row in inserted as List) {
        idMap[row[SupabaseConstants.ingredientName] as String] =
            row[SupabaseConstants.ingredientId] as String;
      }
    }

    // 3. Alle recipe_ingredient-Einträge in einem Batch einfügen
    await supabase.from(SupabaseConstants.recipeIngredientsTable).insert([
      for (final ingredient in ingredients)
        ingredient.toSupabaseRecipeIngredient(recipeId, idMap[ingredient.name]!),
    ]);
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

  @override
  Future<String?> getRecipeTitle({
    required String recipeId,
    required String groupId,
  }) async {
    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select(SupabaseConstants.recipeTitle)
        .eq(SupabaseConstants.recipeId, recipeId)
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .maybeSingle();
    return response?[SupabaseConstants.recipeTitle] as String?;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipeManifest({
    required String groupId,
  }) async {
    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('${SupabaseConstants.recipeId}, ${SupabaseConstants.recipeUpdatedAt}')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .filter(SupabaseConstants.recipeDeletedAt, 'is', null);

    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipesByIds({
    required List<String> ids,
    required String groupId,
  }) async {
    if (ids.isEmpty) return [];

    final response = await supabase
        .from(SupabaseConstants.recipesTable)
        .select('''
          *,
          recipe_categories(categories(id, name)),
          recipe_ingredients(amount, unit, sort_order, group_name, ingredients(name))
        ''')
        .eq(SupabaseConstants.recipeGroupId, groupId)
        .inFilter(SupabaseConstants.recipeId, ids);

    return (response as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> incrementTimesCooked({required String recipeId}) async {
    await supabase.rpc('increment_times_cooked', params: {'recipe_id_param': recipeId});
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

  @override
  Future<void> deleteTimersForRecipe(String recipeId) async {
    await supabase
        .from(SupabaseConstants.recipeTimersTable)
        .delete()
        .eq(SupabaseConstants.recipeTimerRecipeId, recipeId);
  }
}
