import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/common/categories.dart';

final String DEFAULT_CATEGORY = categoryNames[0];
final int DEFAULT_PORTIONS = 4;
final Unit DEFAULT_UNIT = Unit.GRAMM;

final selectedCategoryProvider =
    StateProvider<String>((ref) => DEFAULT_CATEGORY);

final selectedPortionsProvider = StateProvider<int>((ref) => DEFAULT_PORTIONS);

//final selectedUnitProvider = StateProvider<Unit>((ref) => Unit.GRAMM);

class IngredientsNotifier extends StateNotifier<List<Ingredient>> {
  IngredientsNotifier() : super([]);

  void addIngredient() {
    state = [...state, Ingredient(name: '', unit: DEFAULT_UNIT, amount: 0)];
  }

  void updateIngredient(int index, {String? name, Unit? unit, int? amount}) {
    final newState = [...state];
    newState[index] = newState[index].copyWith(
      name: name,
      unit: unit,
      amount: amount,
    );
    state = newState;
  }

  void deleteIngredient(int index) {
    state = [
      ...state.sublist(0, index),
      ...state.sublist(index + 1),
    ];
  }

  void clear() {
    state = [];
  }

  void setIngredients(List<Ingredient> ingredients) {
    state = ingredients;
  }
}

// Ingredients Provider
final ingredientsProvider =
    StateNotifierProvider<IngredientsNotifier, List<Ingredient>>((ref) {
  return IngredientsNotifier();
});

class RecipeValidationResult {
  final bool isValid;
  final String? error;

  RecipeValidationResult({required this.isValid, this.error});
}

extension RecipeValidation on WidgetRef {
  RecipeValidationResult validateRecipe({
    required String name,
    required String instructions,
  }) {
    final ingredients = read(ingredientsProvider);

    // Name validieren
    if (name.isEmpty) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Bitte einen Rezeptnamen eingeben',
      );
    }

    if (name.length < 3) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Rezeptname muss mindestens 3 Zeichen haben',
      );
    }

    // Zutaten validieren
    if (ingredients.isEmpty) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Bitte mindestens eine Zutat hinzufügen',
      );
    }

    final validIngredients =
        ingredients.where((i) => i.name.isNotEmpty && i.amount > 0).toList();

    if (validIngredients.isEmpty) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Bitte gültige Zutaten mit Name und Menge eingeben',
      );
    }

    // Anleitung validieren
    if (instructions.isEmpty) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Bitte eine Anleitung eingeben',
      );
    }

    return RecipeValidationResult(isValid: true);
  }
}
