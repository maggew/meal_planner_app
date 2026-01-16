// lib/data/models/ingredient_model.dart
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

/// Data-Transfer-Objekt für Zutaten
class IngredientModel extends Ingredient {
  IngredientModel({
    required super.name,
    required super.unit,
    required super.amount,
    super.sortOrder = 0,
    super.groupName,
  });

  /// Supabase → Model
  factory IngredientModel.fromSupabase(Map<String, dynamic> data) {
    return IngredientModel(
      name: data[SupabaseConstants.ingredientsTable]
              ?[SupabaseConstants.ingredientName] as String? ??
          '',
      unit: _parseUnit(data[SupabaseConstants.recipeIngredientUnit]),
      amount: double.tryParse(
              data[SupabaseConstants.recipeIngredientAmount]?.toString() ??
                  '0') ??
          0,
      sortOrder: data[SupabaseConstants.recipeIngredientSortOrder] as int? ?? 0,
      groupName: data[SupabaseConstants.recipeIngredientGroupName] as String?,
    );
  }

  /// Entity → Model
  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      name: ingredient.name,
      unit: ingredient.unit,
      amount: ingredient.amount,
      sortOrder: ingredient.sortOrder,
      groupName: ingredient.groupName,
    );
  }

  /// Model → Entity
  Ingredient toEntity() {
    return Ingredient(
      name: name,
      unit: unit,
      amount: amount,
      sortOrder: sortOrder,
      groupName: groupName,
    );
  }

  Map<String, dynamic> toSupabaseRecipeIngredient(
      String recipeId, String ingredientId) {
    return {
      SupabaseConstants.recipeIngredientRecipeId: recipeId,
      SupabaseConstants.recipeIngredientIngredientId: ingredientId,
      SupabaseConstants.recipeIngredientAmount: amount,
      SupabaseConstants.recipeIngredientUnit: unit.name,
      SupabaseConstants.recipeIngredientSortOrder: sortOrder,
      SupabaseConstants.recipeIngredientGroupName: groupName,
    };
  }

  /// Helper: Unit aus supabase parsen
  static Unit _parseUnit(dynamic unitValue) {
    if (unitValue == null) return Unit.GRAMM;

    try {
      return Unit.values.byName(unitValue as String);
    } catch (e) {
      try {
        return Unit.values.firstWhere(
          (u) => u.displayName == unitValue,
          orElse: () => Unit.GRAMM,
        );
      } catch (e) {
        return Unit.GRAMM;
      }
    }
  }
}
