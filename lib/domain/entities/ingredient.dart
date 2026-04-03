import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';

const _sentinel = _Sentinel();

class Ingredient {
  final String name;
  final Unit? unit;
  final String? amount;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  Ingredient scale(double factor) {
    if (amount == null) return this;
    return Ingredient(
      name: name,
      unit: unit,
      amount: AmountScaler.scale(amount!, factor),
    );
  }

  Ingredient copyWith({
    String? name,
    Object? unit = _sentinel,
    Object? amount = _sentinel,
  }) {
    return Ingredient(
      name: name ?? this.name,
      unit: unit == _sentinel ? this.unit : unit as Unit?,
      amount: amount == _sentinel ? this.amount : amount as String?,
    );
  }

  @override
  String toString() {
    return 'Ingredient(name: $name, unit: ${unit?.displayName}, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.unit == unit &&
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(name, unit, amount);
}

class IngredientSection {
  final String title;
  final List<Ingredient> ingredients;
  final String? linkedRecipeId;

  IngredientSection({
    required this.title,
    required this.ingredients,
    this.linkedRecipeId,
  });

  bool get isLinked => linkedRecipeId != null;

  IngredientSection copyWith({
    String? title,
    List<Ingredient>? ingredients,
    Object? linkedRecipeId = _sentinel,
  }) {
    return IngredientSection(
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      linkedRecipeId: linkedRecipeId == _sentinel
          ? this.linkedRecipeId
          : linkedRecipeId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IngredientSection) return false;
    if (other.title != title || other.linkedRecipeId != linkedRecipeId) {
      return false;
    }
    if (other.ingredients.length != ingredients.length) return false;
    for (int i = 0; i < ingredients.length; i++) {
      if (other.ingredients[i] != ingredients[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        title,
        linkedRecipeId,
        Object.hashAll(ingredients),
      );
}

class _Sentinel {
  const _Sentinel();
}
