import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/enums/unit.dart';

class RecipeCacheConverter {
  static LocalRecipesCompanion toCompanion(
    Recipe recipe, {
    required String groupId,
    required List<RecipeTimer> timers,
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
      isDeleted: const Value(false),
      cachedAt: Value(DateTime.now()),
    );
  }

  static Recipe toRecipe(LocalRecipe row) {
    return Recipe(
      id: row.id,
      name: row.name,
      categories: _decodeCategories(row.categoriesJson),
      portions: row.portions,
      ingredientSections: _decodeIngredientSections(row.ingredientSectionsJson),
      instructions: row.instructions,
      imageUrl: row.imageUrl,
      createdAt: row.createdAt,
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
