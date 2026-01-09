// data/repositories/supabase_recipe_repository.dart

import 'dart:io';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';

class SupabaseRecipeRepository implements RecipeRepository {
  final SupabaseClient _supabase;
  final StorageRepository _storage;
  final String _groupId;
  final String _userId;

  SupabaseRecipeRepository({
    required SupabaseClient supabase,
    required StorageRepository storage,
    required String groupId,
    required String userId,
  })  : _supabase = supabase,
        _storage = storage,
        _groupId = groupId,
        _userId = userId;

  // ==================== CREATE ====================

  @override
  Future<String> saveRecipe(Recipe recipe, File? image) async {
    try {
      final recipeId = generateUuid();
      final model = RecipeModel.fromEntity(recipe);

      // 1. Bild hochladen
      String? imageUrl;
      if (image != null) {
        imageUrl = await _storage.uploadImage(image, 'recipe_images');
      }

      // 2. Recipe einfügen
      await _supabase.from(SupabaseConstants.recipesTable).insert(
            model.toSupabase(
              recipeId: recipeId,
              groupId: _groupId,
              userId: _userId,
              imageUrl: imageUrl,
            ),
          );

      // 3. Categories speichern
      await _saveCategories(recipeId, recipe.categories);

      // 4. Ingredients speichern
      await _saveIngredients(recipeId, recipe.ingredients);

      return recipeId;
    } catch (e) {
      throw RecipeCreationException(e.toString());
    }
  }

  Future<void> _saveCategories(String recipeId, List<String> categories) async {
    for (final categoryName in categories) {
      final categoryId = await _upsertCategory(categoryName);

      await _supabase.from(SupabaseConstants.recipeCategoriesTable).insert({
        SupabaseConstants.recipeCategoryRecipeId: recipeId,
        SupabaseConstants.recipeCategoryCategoryId: categoryId,
      });
    }
  }

  Future<String> _upsertCategory(String name) async {
    final existing = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .eq(SupabaseConstants.categoryName, name.toLowerCase())
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.categoryId] as String;
    }

    final categoryId = generateUuid();
    await _supabase.from(SupabaseConstants.categoriesTable).insert({
      SupabaseConstants.categoryId: categoryId,
      SupabaseConstants.categoryName: name.toLowerCase(),
    });

    return categoryId;
  }

  Future<void> _saveIngredients(
      String recipeId, List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      final ingredientId = await _upsertIngredient(ingredient.name);

      await _supabase.from(SupabaseConstants.recipeIngredientsTable).insert({
        SupabaseConstants.recipeIngredientRecipeId: recipeId,
        SupabaseConstants.recipeIngredientIngredientId: ingredientId,
        SupabaseConstants.recipeIngredientAmount: ingredient.amount.toString(),
        SupabaseConstants.recipeIngredientUnit: ingredient.unit.name,
      });
    }
  }

  Future<String> _upsertIngredient(String name) async {
    final existing = await _supabase
        .from(SupabaseConstants.ingredientsTable)
        .select(SupabaseConstants.ingredientId)
        .eq(SupabaseConstants.ingredientName, name.toLowerCase())
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.ingredientId] as String;
    }

    final ingredientId = generateUuid();
    await _supabase.from(SupabaseConstants.ingredientsTable).insert({
      SupabaseConstants.ingredientId: ingredientId,
      SupabaseConstants.ingredientName: name.toLowerCase(),
    });

    return ingredientId;
  }

  // ==================== READ ====================

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select()
          .eq(SupabaseConstants.recipeId, recipeId)
          .maybeSingle();

      if (response == null) return null;

      return await _mapToRecipe(response);
    } catch (e) {
      throw RecipeNotFoundException(recipeId);
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final categoryId = await _getCategoryId(category);
      if (categoryId == null) return [];

      final recipeIds = await _getRecipeIdsByCategory(categoryId);
      if (recipeIds.isEmpty) return [];

      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select()
          .eq(SupabaseConstants.recipeGroupId, _groupId)
          .inFilter(SupabaseConstants.recipeId, recipeIds)
          .order(SupabaseConstants.recipeCreatedAt, ascending: false);

      return await _mapToRecipes(response as List);
    } catch (e) {
      throw RecipeNotFoundException('Kategorie: $category');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) async {
    try {
      final categoryIds = await _getCategoryIds(categories);
      if (categoryIds.isEmpty) return [];

      final recipeIds = await _getRecipeIdsByCategories(categoryIds);
      if (recipeIds.isEmpty) return [];

      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select()
          .eq(SupabaseConstants.recipeGroupId, _groupId)
          .inFilter(SupabaseConstants.recipeId, recipeIds)
          .order(SupabaseConstants.recipeCreatedAt, ascending: false);

      return await _mapToRecipes(response as List);
    } catch (e) {
      throw RecipeNotFoundException('Kategorien: $categories');
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.categoriesTable)
          .select(SupabaseConstants.categoryName)
          .order(SupabaseConstants.categoryName);

      return (response as List)
          .map((data) => data[SupabaseConstants.categoryName] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== UPDATE ====================

  @override
  Future<void> updateRecipe(String recipeId, Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);

      await _supabase
          .from(SupabaseConstants.recipesTable)
          .update(model.toSupabaseUpdate())
          .eq(SupabaseConstants.recipeId, recipeId);

      // Alte Junction-Einträge löschen
      await _deleteRecipeCategories(recipeId);
      await _deleteRecipeIngredients(recipeId);

      // Neue einfügen
      await _saveCategories(recipeId, recipe.categories);
      await _saveIngredients(recipeId, recipe.ingredients);
    } catch (e) {
      throw RecipeUpdateException(e.toString());
    }
  }

  // ==================== DELETE ====================

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      // Bild löschen
      final recipe = await getRecipeById(recipeId);
      if (recipe?.imageUrl != null && recipe!.imageUrl!.isNotEmpty) {
        await _storage.deleteImage(recipe.imageUrl!);
      }

      // Junction-Einträge löschen
      await _deleteRecipeCategories(recipeId);
      await _deleteRecipeIngredients(recipeId);

      // Recipe löschen
      await _supabase
          .from(SupabaseConstants.recipesTable)
          .delete()
          .eq(SupabaseConstants.recipeId, recipeId);
    } catch (e) {
      throw RecipeDeletionException(e.toString());
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<String?> _getCategoryId(String category) async {
    final response = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .eq(SupabaseConstants.categoryName, category.toLowerCase())
        .maybeSingle();

    return response?[SupabaseConstants.categoryId] as String?;
  }

  Future<List<String>> _getCategoryIds(List<String> categories) async {
    final response = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .inFilter(
          SupabaseConstants.categoryName,
          categories.map((c) => c.toLowerCase()).toList(),
        );

    return (response as List)
        .map((c) => c[SupabaseConstants.categoryId] as String)
        .toList();
  }

  Future<List<String>> _getRecipeIdsByCategory(String categoryId) async {
    final response = await _supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .select(SupabaseConstants.recipeCategoryRecipeId)
        .eq(SupabaseConstants.recipeCategoryCategoryId, categoryId);

    return (response as List)
        .map((rc) => rc[SupabaseConstants.recipeCategoryRecipeId] as String)
        .toList();
  }

  Future<List<String>> _getRecipeIdsByCategories(
      List<String> categoryIds) async {
    final response = await _supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .select(SupabaseConstants.recipeCategoryRecipeId)
        .inFilter(SupabaseConstants.recipeCategoryCategoryId, categoryIds);

    return (response as List)
        .map((rc) => rc[SupabaseConstants.recipeCategoryRecipeId] as String)
        .toSet()
        .toList();
  }

  Future<List<String>> _getCategoriesForRecipe(String recipeId) async {
    final response = await _supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .select(
            '${SupabaseConstants.categoriesTable}(${SupabaseConstants.categoryName})')
        .eq(SupabaseConstants.recipeCategoryRecipeId, recipeId);

    return (response as List)
        .map((data) => data[SupabaseConstants.categoriesTable]
            [SupabaseConstants.categoryName] as String)
        .toList();
  }

  Future<List<Ingredient>> _getIngredientsForRecipe(String recipeId) async {
    final response = await _supabase
        .from(SupabaseConstants.recipeIngredientsTable)
        .select(
          '${SupabaseConstants.recipeIngredientAmount}, '
          '${SupabaseConstants.recipeIngredientUnit}, '
          '${SupabaseConstants.ingredientsTable}(${SupabaseConstants.ingredientName})',
        )
        .eq(SupabaseConstants.recipeIngredientRecipeId, recipeId);

    return (response as List).map((data) {
      return Ingredient(
        name: data[SupabaseConstants.ingredientsTable]
            [SupabaseConstants.ingredientName] as String,
        amount: double.tryParse(
                data[SupabaseConstants.recipeIngredientAmount] ?? '0') ??
            0,
        unit: UnitParser.parse(data[SupabaseConstants.recipeIngredientUnit]) ??
            Unit.GRAMM,
      );
    }).toList();
  }

  Future<Recipe> _mapToRecipe(Map<String, dynamic> data) async {
    final recipeId = data[SupabaseConstants.recipeId] as String;
    final ingredients = await _getIngredientsForRecipe(recipeId);
    final categories = await _getCategoriesForRecipe(recipeId);

    return RecipeModel.fromSupabase(
      data,
      ingredients: ingredients,
      categories: categories,
    );
  }

  Future<List<Recipe>> _mapToRecipes(List<dynamic> data) async {
    final recipes = <Recipe>[];
    for (final item in data) {
      recipes.add(await _mapToRecipe(item));
    }
    return recipes;
  }

  Future<void> _deleteRecipeCategories(String recipeId) async {
    await _supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .delete()
        .eq(SupabaseConstants.recipeCategoryRecipeId, recipeId);
  }

  Future<void> _deleteRecipeIngredients(String recipeId) async {
    await _supabase
        .from(SupabaseConstants.recipeIngredientsTable)
        .delete()
        .eq(SupabaseConstants.recipeIngredientRecipeId, recipeId);
  }
}

