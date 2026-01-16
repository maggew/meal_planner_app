import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/common/categories.dart';

part 'add_recipe_provider.g.dart';

final String DEFAULT_CATEGORY = categoryNames[0];
final int DEFAULT_PORTIONS = 4;
final Unit DEFAULT_UNIT = Unit.GRAMM;

@Riverpod(keepAlive: true)
class SelectedCategories extends _$SelectedCategories {
  @override
  List<String> build() => [];

  void toggle(String category) {
    if (state.contains(category)) {
      state = state.where((c) => c != category).toList();
    } else {
      state = [...state, category];
    }
  }

  void set(List<String> categories) => state = categories;

  void clear() {
    state = [];
  }
}

@Riverpod(keepAlive: true)
class SelectedPortions extends _$SelectedPortions {
  @override
  int build() => DEFAULT_PORTIONS;

  void set(int portions) => state = portions;
}

// @Riverpod(keepAlive: true)
// class Ingredients extends _$Ingredients {
//   @override
//   List<Ingredient> build() => [];
//
//   void addIngredient({String? groupName}) {
//     final nextSortOrder =
//         state.isEmpty ? 0 : state.map((i) => i.sortOrder).reduce(max) + 1;
//     state = [
//       ...state,
//       Ingredient(
//         name: '',
//         unit: DEFAULT_UNIT,
//         amount: 0,
//         sortOrder: nextSortOrder,
//         groupName: groupName,
//       )
//     ];
//   }
//
//   void updateIngredient(int index,
//       {String? name, Unit? unit, double? amount, String? groupName}) {
//     final newState = [...state];
//     newState[index] = newState[index].copyWith(
//       name: name,
//       unit: unit,
//       amount: amount,
//       groupName: groupName,
//     );
//     state = newState;
//   }
//
//   void deleteIngredient(int index) {
//     state = [
//       ...state.sublist(0, index),
//       ...state.sublist(index + 1),
//     ];
//   }
//
//   void reorderIngredient(int oldIndex, int newIndex) {
//     if (oldIndex < newIndex) {
//       newIndex -= 1;
//     }
//     final newState = [...state];
//     final item = newState.removeAt(oldIndex);
//     newState.insert(newIndex, item);
//     state = newState;
//   }
//
//   List<Ingredient> getIngredientsWithSortOrder() {
//     return state.asMap().entries.map((entry) {
//       return entry.value.copyWith(sortOrder: entry.key);
//     }).toList();
//   }
//
//   void clear() {
//     state = [];
//   }
//
//   void setIngredients(List<Ingredient> ingredients) {
//     state = ingredients.asMap().entries.map((entry) {
//       return entry.value.sortOrder == 0 && entry.key > 0
//           ? entry.value.copyWith(sortOrder: entry.key)
//           : entry.value;
//     }).toList();
//   }
// }

class RecipeValidationResult {
  final bool isValid;
  final String? error;
  RecipeValidationResult({required this.isValid, this.error});
}

extension RecipeValidation on WidgetRef {
  RecipeValidationResult validateRecipe({
    required String name,
    required String instructions,
    required List<Ingredient> ingredients,
  }) {
    //final ingredients = read(ingredientsProvider);

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
    if (instructions.isEmpty) {
      return RecipeValidationResult(
        isValid: false,
        error: 'Bitte eine Anleitung eingeben',
      );
    }
    return RecipeValidationResult(isValid: true);
  }
}
