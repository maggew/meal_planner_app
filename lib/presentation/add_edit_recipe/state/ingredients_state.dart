import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_section_form.dart';

class AddEditRecipeIngredientsState {
  final List<IngredientSectionForm> sections;
  final bool isAnalyzing;

  const AddEditRecipeIngredientsState({
    required this.sections,
    required this.isAnalyzing,
  });

  factory AddEditRecipeIngredientsState.initial(
    List<IngredientSection>? initialSections,
  ) {
    // Neues Rezept
    if (initialSections == null || initialSections.isEmpty) {
      return AddEditRecipeIngredientsState(
        sections: [
          IngredientSectionForm(
            title: 'Zutaten',
            items: [], //[IngredientFormItem.empty()],
          ),
        ],
        isAnalyzing: false,
      );
    }

    // Rezept bearbeiten
    return AddEditRecipeIngredientsState(
      sections: initialSections
          .map(
            (section) => IngredientSectionForm(
              title: section.title,
              items:
                  section.items.map(IngredientFormItem.fromIngredient).toList(),
            ),
          )
          .toList(),
      isAnalyzing: false,
    );
  }

  AddEditRecipeIngredientsState copyWith({
    List<IngredientSectionForm>? sections,
    bool? isAnalyzing,
  }) {
    return AddEditRecipeIngredientsState(
      sections: sections ?? this.sections,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}
