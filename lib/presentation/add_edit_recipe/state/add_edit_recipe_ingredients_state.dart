import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/add_edit_recipe_ingredient_form_item.dart';

class AddEditRecipeIngredientsState {
  final List<IngredientFormItem> items;
  final bool isAnalyzing;

  const AddEditRecipeIngredientsState({
    required this.items,
    required this.isAnalyzing,
  });

  factory AddEditRecipeIngredientsState.initial(
      List<Ingredient>? initialIngredients) {
    return AddEditRecipeIngredientsState(
        items: (initialIngredients == null || initialIngredients.isEmpty)
            ? [IngredientFormItem.empty()]
            : initialIngredients
                .map(IngredientFormItem.fromIngredient)
                .toList(),
        isAnalyzing: false);
  }

  AddEditRecipeIngredientsState copyWith({
    List<IngredientFormItem>? items,
    bool? isAnalyzing,
  }) {
    return AddEditRecipeIngredientsState(
      items: items ?? this.items,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}
