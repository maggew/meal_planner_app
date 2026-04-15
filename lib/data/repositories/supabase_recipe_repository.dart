import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/data/model/recipe_model.dart';
import 'package:meal_planner/data/model/recipe_timer_model.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/core/utils/recipe_link_parser.dart';
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

      // 1. Bild hochladen (oder vorher hochgeladene URL verwenden)
      String? imageUrl = recipe.imageUrl;
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

      // 3+4. Categories + Ingredients parallel speichern
      final ingredientModels = _buildIngredientModels(recipe);

      await Future.wait([
        _remote.saveRecipeCategories(
            recipeId: recipeId, categories: recipe.categories, groupId: _groupId),
        _remote.saveRecipeIngredients(
            recipeId: recipeId, ingredients: ingredientModels),
      ]);

      return recipeId;
    } catch (e) {
      throw RecipeCreationException(e.toString());
    }
  }

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
  Future<List<Recipe>> getRecipesByCategoryId({
    required String categoryId,
    required RecipeSortOption sortOption,
    required bool isDeleted,
  }) async {
    try {
      final data = await _remote.getRecipesByCategoryId(
        categoryId: categoryId,
        groupId: _groupId,
        isDeleted: isDeleted,
        sortOption: sortOption,
      );

      return data
          .map(
              (recipeData) => RecipeModel.fromSupabaseWithRelations(recipeData))
          .toList();
    } catch (e) {
      debugPrint("Error fetching recipes by category: $e");
      throw RecipeNotFoundException('Kategorie: $categoryId');
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
    } catch (e) {
      debugPrint("Error fetching recipes by categories: $e");
      throw RecipeNotFoundException('Kategorien: $categories');
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      return await _remote.getAllCategories(groupId: _groupId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String?> getRecipeTitle(String recipeId) async {
    try {
      return await _remote.getRecipeTitle(
          recipeId: recipeId, groupId: _groupId);
    } catch (e) {
      return null;
    }
  }

  // ==================== MANIFEST / BATCH (for delta-sync) ====================

  Future<List<Map<String, dynamic>>> getRecipeManifest() {
    return _remote.getRecipeManifest(groupId: _groupId);
  }

  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
    final data = await _remote.getRecipesByIds(ids: ids, groupId: _groupId);
    return data
        .map((d) => RecipeModel.fromSupabaseWithRelations(d))
        .toList();
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
        // Upload zuerst — wenn er schlägt fehl, bleibt das alte Bild erhalten.
        imageUrl = await _storage.uploadImage(
            newImage, FirebaseConstants.imagePathRecipe);
        if (recipe.imageUrl != null) {
          await _storage.deleteImage(recipe.imageUrl!);
        }
      }

      final updatedRecipe = recipe.copyWith(imageUrl: imageUrl);
      final model = RecipeModel.fromEntity(updatedRecipe);

      await _remote.updateRecipe(recipeId, model.toSupabaseUpdate());

      // Alte Junction-Einträge parallel löschen
      await Future.wait([
        _remote.deleteRecipeCategories(recipeId),
        _remote.deleteRecipeIngredients(recipeId),
      ]);

      // Categories + Ingredients parallel speichern
      final ingredientModels = _buildIngredientModels(updatedRecipe);

      await Future.wait([
        _remote.saveRecipeCategories(
            recipeId: recipeId, categories: recipe.categories, groupId: _groupId),
        _remote.saveRecipeIngredients(
            recipeId: recipeId, ingredients: ingredientModels),
      ]);
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

  // ==================== SEARCH ====================

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    // SupabaseRecipeRepository has no local cache — not supported.
    // Use CachedRecipeRepository for search.
    return [];
  }

  // ==================== TIMER ====================
  @override
  Future<List<RecipeTimer>> getTimersForRecipe(String recipeId) async {
    try {
      final data = await _remote.getTimersForRecipe(recipeId);
      return data
          .map((row) => RecipeTimerModel.fromSupabase(row).toEntity())
          .toList();
    } catch (e) {
      throw RecipeTimerException('Fehler beim Laden der Timer: $e');
    }
  }

  @override
  Future<RecipeTimer> upsertTimer(RecipeTimer timer) async {
    try {
      final model = RecipeTimerModel.fromEntity(timer);
      final data = await _remote.upsertTimer(model.toSupabase());
      return RecipeTimerModel.fromSupabase(data).toEntity();
    } catch (e) {
      throw RecipeTimerException('Fehler beim Speichern des Timers: $e');
    }
  }

  @override
  Future<void> deleteTimer(String recipeId, int stepIndex) async {
    try {
      await _remote.deleteTimer(recipeId, stepIndex);
    } catch (e) {
      throw RecipeTimerException('Fehler beim Löschen des Timers: $e');
    }
  }

  @override
  Future<void> incrementTimesCooked(String recipeId) async {
    await _remote.incrementTimesCooked(recipeId: recipeId);
  }

  // ==================== HELPERS ====================

  /// Builds IngredientModels from recipe sections.
  /// Linked sections encode the recipe link in the group_name.
  List<IngredientModel> _buildIngredientModels(Recipe recipe) {
    final List<IngredientModel> models = [];
    for (final section in recipe.ingredientSections) {
      final groupName = section.isLinked
          ? RecipeLinkParser.encode(section.title, section.linkedRecipeId!)
          : section.title;
      for (int i = 0; i < section.ingredients.length; i++) {
        models.add(IngredientModel.fromEntity(
          section.ingredients[i],
          groupName: groupName,
          sortOrder: i,
        ));
      }
      // Linked sections have no own ingredients — insert a placeholder
      // so the group_name is persisted in the junction table.
      if (section.isLinked && section.ingredients.isEmpty) {
        models.add(IngredientModel(
          name: '',
          unit: null,
          amount: null,
          groupName: groupName,
          sortOrder: 0,
        ));
      }
    }
    return models;
  }
}
