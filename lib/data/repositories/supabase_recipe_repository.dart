// data/repositories/supabase_recipe_repository.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
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
        imageUrl = await _storage.uploadImage(
            image, FirebaseConstants.imagePathRecipe);
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
      //await _saveCategories(recipeId, recipe.categories);
      await _saveCategories(recipeId, [recipe.category]);

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
        .eq(SupabaseConstants.ingredientName, name)
        .maybeSingle();

    if (existing != null) {
      return existing[SupabaseConstants.ingredientId] as String;
    }

    final ingredientId = generateUuid();
    await _supabase.from(SupabaseConstants.ingredientsTable).insert({
      SupabaseConstants.ingredientId: ingredientId,
      SupabaseConstants.ingredientName: name,
    });

    return ingredientId;
  }

  // ==================== READ ====================

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select('''
          *,
          recipe_categories(categories(name)),
          recipe_ingredients(amount, unit, ingredients(name))
        ''')
          .eq(SupabaseConstants.recipeId, recipeId)
          .eq(SupabaseConstants.recipeGroupId, _groupId)
          .maybeSingle();

      if (response == null) return null;
      return RecipeModel.fromSupabaseWithRelations(response);
    } catch (e) {
      throw RecipeNotFoundException(recipeId);
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select('''
          *,
          recipe_categories!inner(categories!inner(name)),
          recipe_ingredients(amount, unit, ingredients(name))
        ''')
          .eq(SupabaseConstants.recipeGroupId, _groupId)
          .eq('recipe_categories.categories.name', category.toLowerCase())
          .order(SupabaseConstants.recipeCreatedAt, ascending: false);

      return (response as List)
          .map((data) => RecipeModel.fromSupabaseWithRelations(data))
          .toList();
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
      throw RecipeNotFoundException('Kategorie: $category');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.recipesTable)
          .select('''
          *,
          recipe_categories!inner(categories!inner(name)),
          recipe_ingredients(amount, unit, ingredients(name))
        ''')
          .eq(SupabaseConstants.recipeGroupId, _groupId)
          .inFilter('recipe_categories.categories.name',
              categories.map((c) => c.toLowerCase()).toList())
          .order(SupabaseConstants.recipeCreatedAt, ascending: false);

      return (response as List)
          .map((data) => RecipeModel.fromSupabaseWithRelations(data))
          .toList();
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
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
  Future<void> updateRecipe(Recipe recipe, File? newImage) async {
    try {
      final String? recipeId = recipe.id;
      if (recipeId == null) {
        throw RecipeUpdateException("Recipe has no ID");
      }

      String? imageUrl = recipe.imageUrl;

      if (newImage != null) {
        if (recipe.imageUrl != null) {
          await _storage.deleteImage(recipe.imageUrl!);
        }
        imageUrl = await _storage.uploadImage(
            newImage, FirebaseConstants.imagePathRecipe);
      }

      final updatedRecipe = recipe.copyWith(imageUrl: imageUrl);
      final model = RecipeModel.fromEntity(updatedRecipe);
      await _supabase
          .from(SupabaseConstants.recipesTable)
          .update(model.toSupabaseUpdate())
          .eq(SupabaseConstants.recipeId, recipeId);

      // Alte Junction-Einträge löschen
      await _deleteRecipeCategories(recipeId);
      await _deleteRecipeIngredients(recipeId);

      // Neue einfügen
      //await _saveCategories(recipeId, recipe.categories);
      await _saveCategories(recipeId, [recipe.category]);
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
