import 'dart:io';

import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/add_edit_recipe_ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/state/add_edit_recipe_ingredients_state.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_edit_recipe_ingredients_provider.g.dart';

@riverpod
class AddEditRecipeIngredients extends _$AddEditRecipeIngredients {
  @override
  AddEditRecipeIngredientsState build(
    List<Ingredient>? initialIngredients,
  ) {
    return AddEditRecipeIngredientsState.initial(initialIngredients);
  }

  // ---------- Actions ----------

  void addIngredient({String? groupName}) {
    state = state.copyWith(
      items: [
        ...state.items,
        IngredientFormItem.empty(groupName: groupName),
      ],
    );
  }

  void deleteIngredient(int index) {
    final items = [...state.items];
    final removed = items.removeAt(index);
    removed.dispose();

    state = state.copyWith(items: items);
  }

  void updateName(int index, String value) {
    final item = state.items[index];
    final updated = item.copyWith(
      ingredient: item.ingredient.copyWith(name: value),
    );

    final items = [...state.items]..[index] = updated;
    state = state.copyWith(items: items);
  }

  void updateAmount(int index, double value) {
    final item = state.items[index];
    final updated = item.copyWith(
      ingredient: item.ingredient.copyWith(amount: value),
    );

    final items = [...state.items]..[index] = updated;
    state = state.copyWith(items: items);
  }

  void updateUnit(int index, Unit unit) {
    final item = state.items[index];
    final updated = item.copyWith(
      ingredient: item.ingredient.copyWith(unit: unit),
    );

    final items = [...state.items]..[index] = updated;
    state = state.copyWith(items: items);
  }

  void reorder(int oldIndex, int newIndex) {
    final items = [...state.items];
    if (oldIndex < newIndex) newIndex -= 1;

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(items: items);
  }

  void applyAnalysis(List<Ingredient> ingredients) {
    for (final item in state.items) {
      item.dispose();
    }

    state = state.copyWith(
      items:
          ingredients.map((i) => IngredientFormItem.fromIngredient(i)).toList(),
    );
  }

  List<Ingredient> buildIngredientsForSave() {
    return state.items
        .asMap()
        .entries
        .map(
          (e) => e.value.ingredient.copyWith(sortOrder: e.key),
        )
        .toList();
  }

  Future<void> analyzeIngredientsFromImage(
      {required bool pickImageFromCamera}) async {
    state = state.copyWith(isAnalyzing: true);

    final imageManager = ref.read(imageManagerProvider.notifier);
    final analysisNotifier = ref.read(recipeAnalysisProvider.notifier);

    if (pickImageFromCamera) {
      await imageManager.pickImageFromCamera(
          imageType: AnalysisImageType.ingredients);
    } else {
      await imageManager.pickImageFromGallery(
          imageType: AnalysisImageType.ingredients);
    }

    final image = ref.read(imageManagerProvider).ingredientsImage;

    if (image == null) {
      state = state.copyWith(isAnalyzing: false);
      return;
    }

    await analysisNotifier.analyzeImage(image: image, isIngredientImage: true);

    final analysisState = ref.read(recipeAnalysisProvider);

    analysisState.when(
      data: (data) {
        final List<Ingredient>? ingredients = data?.ingredients;
        if (ingredients == null) {
          state = state.copyWith(isAnalyzing: false);
          return;
        }
        for (final item in state.items) {
          item.dispose();
        }

        state = state.copyWith(
          items: ingredients.map(IngredientFormItem.fromIngredient).toList(),
          isAnalyzing: false,
        );
      },
      loading: () {
        print("==================");
        print(
            "loading in \'analyzseIngredientsFromImage\', which shouldn't happen!");
        print("==================");
      },
      error: (error, stackTrace) {
        print("error in \'analyzseIngredientsFromImage\'");
        print("error: $error");
        state = state.copyWith(isAnalyzing: false);
      },
    );
  }
}
