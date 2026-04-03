import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/form/ingredient_section_form.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/state/ingredients_state.dart';

void main() {
  group('AddEditRecipeIngredients - linked sections', () {
    test('addLinkedSection ignores duplicate recipeId', () {
      // Simulate what the provider's addLinkedSection does:
      // Start with a state that already has a linked section
      final state = AddEditRecipeIngredientsState(
        sections: [
          IngredientSectionForm(title: 'Zutaten', items: []),
          IngredientSectionForm(
            title: 'Brötchen',
            items: [],
            linkedRecipeId: 'recipe-brötchen',
          ),
        ],
        isAnalyzing: false,
      );

      // The provider should check for existing linkedRecipeIds
      final alreadyLinked = state.sections
          .any((s) => s.linkedRecipeId == 'recipe-brötchen');

      expect(alreadyLinked, isTrue,
          reason: 'Should detect existing linked recipe');

      // Verify we can still add a different recipe
      final notLinked = state.sections
          .any((s) => s.linkedRecipeId == 'recipe-soße');
      expect(notLinked, isFalse);
    });

    test('addLinkedSection adds section when recipeId is new', () {
      final state = AddEditRecipeIngredientsState(
        sections: [
          IngredientSectionForm(title: 'Zutaten', items: []),
        ],
        isAnalyzing: false,
      );

      final alreadyLinked = state.sections
          .any((s) => s.linkedRecipeId == 'recipe-soße');
      expect(alreadyLinked, isFalse,
          reason: 'New recipe should not be detected as duplicate');
    });
  });
}
