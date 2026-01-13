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
    );
  }

  /// Entity → Model
  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      name: ingredient.name,
      unit: ingredient.unit,
      amount: ingredient.amount,
    );
  }

  /// Model → Entity
  Ingredient toEntity() {
    return Ingredient(
      name: name,
      unit: unit,
      amount: amount,
    );
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
