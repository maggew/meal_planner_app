import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/carb_tag_detector.dart';

class RecipeCacheConverter {
  static LocalRecipesCompanion toCompanion(
    Recipe recipe, {
    required String groupId,
    required List<RecipeTimer> timers,
    DateTime? updatedAt,
  }) {
    return LocalRecipesCompanion(
      id: Value(recipe.id!),
      groupId: Value(groupId),
      name: Value(recipe.name),
      portions: Value(recipe.portions),
      instructions: Value(recipe.instructions),
      imageUrl: Value(recipe.imageUrl),
      createdAt: Value(recipe.createdAt),
      categoriesJson: Value(jsonEncode(recipe.categories)),
      ingredientSectionsJson: Value(_encodeIngredientSections(recipe.ingredientSections)),
      timersJson: Value(_encodeTimers(timers)),
      carbTagsJson: Value(jsonEncode(recipe.carbTags)),
      timesCooked: Value(recipe.timesCooked),
      updatedAt: Value(updatedAt),
      isDeleted: const Value(false),
      cachedAt: Value(DateTime.now()),
    );
  }

  static Recipe toRecipe(LocalRecipe row) {
    final ingredientSections = _decodeIngredientSections(row.ingredientSectionsJson);
    var carbTags = _decodeCarbTags(row.carbTagsJson);
    // Backfill: auto-detect if empty
    if (carbTags.isEmpty) {
      carbTags = CarbTagDetector.detect(ingredientSections)
          .map((t) => t.value)
          .toList();
    }
    return Recipe(
      id: row.id,
      name: row.name,
      categories: _decodeCategories(row.categoriesJson),
      portions: row.portions,
      ingredientSections: ingredientSections,
      instructions: row.instructions,
      imageUrl: row.imageUrl,
      createdAt: row.createdAt,
      carbTags: carbTags,
      timesCooked: row.timesCooked,
    );
  }

  static List<RecipeTimer> toTimers(LocalRecipe row) {
    return _decodeTimers(row.timersJson, row.id);
  }

  // ==================== ENCODE ====================

  static String _encodeIngredientSections(List<IngredientSection> sections) {
    return jsonEncode(sections.map((section) => {
      'title': section.title,
      'ingredients': section.ingredients.map((ing) => {
        'name': ing.name,
        'unit': ing.unit?.name,
        'amount': ing.amount,
      }).toList(),
      if (section.linkedRecipeId != null)
        'linkedRecipeId': section.linkedRecipeId,
    }).toList());
  }

  static String _encodeTimers(List<RecipeTimer> timers) {
    return jsonEncode(timers.map((t) => {
      'id': t.id,
      'stepIndex': t.stepIndex,
      'timerName': t.timerName,
      'durationSeconds': t.durationSeconds,
    }).toList());
  }

  // ==================== DECODE ====================

  static List<String> _decodeCategories(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.cast<String>();
  }

  static List<String> _decodeCarbTags(String json) {
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  static List<IngredientSection> _decodeIngredientSections(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((sectionMap) {
      final ingredients = (sectionMap['ingredients'] as List<dynamic>)
          .map((ingMap) => Ingredient(
                name: ingMap['name'] as String,
                unit: ingMap['unit'] != null
                    ? Unit.values.byName(ingMap['unit'] as String)
                    : null,
                amount: ingMap['amount'] as String?,
              ))
          .toList();

      return IngredientSection(
        title: sectionMap['title'] as String,
        ingredients: ingredients,
        linkedRecipeId: sectionMap['linkedRecipeId'] as String?,
      );
    }).toList();
  }

  static List<RecipeTimer> _decodeTimers(String json, String recipeId) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded
        .map((t) => RecipeTimer(
              id: t['id'] as String?,
              recipeId: recipeId,
              stepIndex: t['stepIndex'] as int,
              timerName: t['timerName'] as String,
              durationSeconds: t['durationSeconds'] as int,
            ))
        .toList();
  }
}
