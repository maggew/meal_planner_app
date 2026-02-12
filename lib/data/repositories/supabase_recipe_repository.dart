import 'dart:developer';
import 'dart:io';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/exceptions/recipe_exceptions.dart';

class SupabaseRecipeRepository implements RecipeRepository {
  final StorageRepository _storage;
  final RecipeRemoteDatasource _remote;
  final String _groupId;

  SupabaseRecipeRepository({
    required SupabaseClient supabase,
    required StorageRepository storage,
    required RecipeRemoteDatasource remote,
    required String groupId,
  })  : _storage = storage,
        _remote = remote,
        _groupId = groupId;

  // ==================== CREATE ====================

  @override
  Future<String> saveRecipe(
      Recipe recipe, File? image, String createdBy) async {
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
      await _remote.insertRecipe(
        recipeId: recipeId,
        model: model,
        groupId: _groupId,
        createdBy: createdBy,
        imageUrl: imageUrl,
      );

      // 3. Categories speichern
      //await _saveCategories(recipeId, recipe.categories);
      await _remote.saveRecipeCategories(
          recipeId: recipeId, categories: recipe.categories);

      final List<IngredientModel> ingredientModels = [];
      for (final section in recipe.ingredientSections) {
        for (int i = 0; i < section.ingredients.length; i++) {
          final ingredient = section.ingredients[i];

          ingredientModels.add(IngredientModel.fromEntity(
            ingredient,
            groupName: section.title,
            sortOrder: i,
          ));
        }
      }
      // 4. Ingredients speichern
      await _remote.saveRecipeIngredients(
        recipeId: recipeId,
        ingredients: ingredientModels,
      );

      return recipeId;
    } catch (e) {
      throw RecipeCreationException(e.toString());
    }
  }

  // Future<void> _saveCategories(String recipeId, List<String> categories) async {
  //   for (final categoryName in categories) {
  //     final categoryId = await _upsertCategory(categoryName);
  //
  //     await _supabase.from(SupabaseConstants.recipeCategoriesTable).insert({
  //       SupabaseConstants.recipeCategoryRecipeId: recipeId,
  //       SupabaseConstants.recipeCategoryCategoryId: categoryId,
  //     });
  //   }
  // }
  //
  // Future<String> _upsertCategory(String name) async {
  //   final existing = await _supabase
  //       .from(SupabaseConstants.categoriesTable)
  //       .select(SupabaseConstants.categoryId)
  //       .eq(SupabaseConstants.categoryName, name.toLowerCase())
  //       .maybeSingle();
  //
  //   if (existing != null) {
  //     return existing[SupabaseConstants.categoryId] as String;
  //   }
  //
  //   final categoryId = generateUuid();
  //   await _supabase.from(SupabaseConstants.categoriesTable).insert({
  //     SupabaseConstants.categoryId: categoryId,
  //     SupabaseConstants.categoryName: name.toLowerCase(),
  //   });
  //
  //   return categoryId;
  // }

  // Future<void> _saveIngredients(
  //     String recipeId, List<Ingredient> ingredients) async {
  //   for (final ingredient in ingredients) {
  //     final ingredientId = await _upsertIngredient(ingredient.name);
  //     final model = IngredientModel.fromEntity(ingredient);
  //
  //     await _supabase
  //         .from(SupabaseConstants.recipeIngredientsTable)
  //         .insert(model.toSupabaseRecipeIngredient(recipeId, ingredientId));
  //   }
  // }
  //
  // Future<String> _upsertIngredient(String name) async {
  //   final existing = await _supabase
  //       .from(SupabaseConstants.ingredientsTable)
  //       .select(SupabaseConstants.ingredientId)
  //       .eq(SupabaseConstants.ingredientName, name)
  //       .maybeSingle();
  //
  //   if (existing != null) {
  //     return existing[SupabaseConstants.ingredientId] as String;
  //   }
  //
  //   final ingredientId = generateUuid();
  //   await _supabase.from(SupabaseConstants.ingredientsTable).insert({
  //     SupabaseConstants.ingredientId: ingredientId,
  //     SupabaseConstants.ingredientName: name,
  //   });
  //
  //   return ingredientId;
  // }

  // ==================== READ ====================

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final response =
          await _remote.getRecipeById(recipeId: recipeId, groupId: _groupId);

      if (response == null) return null;
      return RecipeModel.fromSupabaseWithRelations(response);
    } catch (e) {
      throw RecipeNotFoundException(recipeId);
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(
      String category, bool isDeleted) async {
    try {
      final data = await _remote.getRecipesByCategory(
        category: category,
        groupId: _groupId,
        isDeleted: isDeleted,
      );
      return data
          .map(
              (recipeData) => RecipeModel.fromSupabaseWithRelations(recipeData))
          .toList();
    } catch (e, stackTrace) {
      log("Error fetching recipes by category",
          error: e, stackTrace: stackTrace);
      throw RecipeNotFoundException('Kategorie: $category');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) async {
    try {
      final data = await _remote.getRecipesByCategories(
          categories: categories, groupId: _groupId);
      return data
          .map(
              (recipeData) => RecipeModel.fromSupabaseWithRelations(recipeData))
          .toList();
    } catch (e, stackTrace) {
      log("Error fetching recipes by categories",
          error: e, stackTrace: stackTrace);
      throw RecipeNotFoundException('Kategorien: $categories');
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      return await _remote.getAllCategories();
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
      await _remote.updateRecipe(recipeId, model.toSupabaseUpdate());
      // Alte Junction-Einträge löschen
      await _remote.deleteRecipeCategories(recipeId);
      await _remote.deleteRecipeIngredients(recipeId);

      await _remote.saveRecipeCategories(
          recipeId: recipeId, categories: recipe.categories);

      final List<IngredientModel> ingredientModels = [];

      for (final section in recipe.ingredientSections) {
        for (int i = 0; i < section.ingredients.length; i++) {
          final ingredient = section.ingredients[i];

          ingredientModels.add(
            IngredientModel.fromEntity(
              ingredient,
              groupName: section.title,
              sortOrder: i,
            ),
          );
        }
      }

      await _remote.saveRecipeIngredients(
        recipeId: recipeId,
        ingredients: ingredientModels,
      );
    } catch (e) {
      throw RecipeUpdateException(e.toString());
    }
  }

  // ==================== DELETE ====================

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _remote.softDeleteRecipe(recipeId);
    } catch (e) {
      throw RecipeDeletionException(e.toString());
    }
  }

  @override
  Future<void> hardDeleteRecipe(String recipeId) async {
    try {
      final recipe = await getRecipeById(recipeId);

      if (recipe?.imageUrl != null && recipe!.imageUrl!.isNotEmpty) {
        await _storage.deleteImage(recipe.imageUrl!);
      }

      await _remote.deleteRecipeCategories(recipeId);
      await _remote.deleteRecipeIngredients(recipeId);
      await _remote.hardDeleteRecipe(recipeId);
    } catch (e) {
      throw RecipeDeletionException(e.toString());
    }
  }

  @override
  Future<void> restoreRecipe(String recipeId) async {
    try {
      await _remote.restoreRecipe(recipeId);
    } catch (e) {
      throw RecipeUpdateException(e.toString());
    }
  }

  // @override
  // Future<void> deleteRecipe(String recipeId) async {
  //   try {
  //     // Bild löschen
  //     final recipe = await getRecipeById(recipeId);
  //     if (recipe?.imageUrl != null && recipe!.imageUrl!.isNotEmpty) {
  //       await _storage.deleteImage(recipe.imageUrl!);
  //     }
  //
  //     // Junction-Einträge löschen
  //     await _remote.deleteRecipeCategories(recipeId);
  //     await _remote.deleteRecipeIngredients(recipeId);
  //
  //     // Recipe löschen
  //     await _remote.deleteRecipe(recipeId);
  //   } catch (e) {
  //     throw RecipeDeletionException(e.toString());
  //   }
  // }

  // ==================== PRIVATE HELPERS ====================

//   Future<void> _deleteRecipeCategories(String recipeId) async {
//     await _supabase
//         .from(SupabaseConstants.recipeCategoriesTable)
//         .delete()
//         .eq(SupabaseConstants.recipeCategoryRecipeId, recipeId);
//   }
//
//   Future<void> _deleteRecipeIngredients(String recipeId) async {
//     await _supabase
//         .from(SupabaseConstants.recipeIngredientsTable)
//         .delete()
//         .eq(SupabaseConstants.recipeIngredientRecipeId, recipeId);
//   }
}
