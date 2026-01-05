// lib/data/models/ingredient_model.dart
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';

/// Data-Transfer-Objekt für Zutaten
class IngredientModel extends Ingredient {
  IngredientModel({
    required super.name,
    required super.unit,
    required super.amount,
  });

  /// Firestore → Model
  factory IngredientModel.fromFirestore(Map<String, dynamic> data) {
    return IngredientModel(
      name: data['name'] as String? ?? '',
      unit: _parseUnit(data['unit']),
      amount: data['amount'] as double? ?? 0,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unit': unit.name, // Enum.name für Konsistenz
      'amount': amount,
    };
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

  /// Helper: Unit aus Firestore parsen (robust)
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
