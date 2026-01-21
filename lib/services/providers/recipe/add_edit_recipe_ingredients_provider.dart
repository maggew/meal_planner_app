import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_section_form.dart';
import 'package:meal_planner/presentation/add_edit_recipe/state/ingredients_state.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_edit_recipe_ingredients_provider.g.dart';

@riverpod
class AddEditRecipeIngredients extends _$AddEditRecipeIngredients {
  @override
  AddEditRecipeIngredientsState build(
    List<IngredientSection>? initialSections,
  ) {
    return AddEditRecipeIngredientsState.initial(initialSections);
  }

  // ------------------------------------------------------------
  // Section Actions
  // ------------------------------------------------------------

  void addSection() {
    state.sections.add(
      IngredientSectionForm(
        items: [IngredientFormItem.empty()],
      ),
    );

    state = state.copyWith(sections: [...state.sections]);
  }

  void renameSection(int sectionIndex, String title) {
    state.sections[sectionIndex].titleController.text = title;
  }

  void removeSection(int sectionIndex) {
    final section = state.sections.removeAt(sectionIndex);
    section.dispose();
    state = state.copyWith(sections: [...state.sections]);
  }

  // ------------------------------------------------------------
  // Ingredient Actions
  // ------------------------------------------------------------

  void addIngredient(int sectionIndex) {
    final section = state.sections[sectionIndex];
    section.items.add(IngredientFormItem.empty());

    state = state.copyWith(sections: [...state.sections]);
  }

  void deleteIngredient(int sectionIndex, int itemIndex) {
    final section = state.sections[sectionIndex];
    final item = section.items.removeAt(itemIndex);

    item.dispose();

    state = state.copyWith(sections: [...state.sections]);
  }

  void reorderIngredient(
    int sectionIndex,
    int oldIndex,
    int newIndex,
  ) {
    final section = state.sections[sectionIndex];

    if (oldIndex < newIndex) newIndex -= 1;

    final item = section.items.removeAt(oldIndex);
    section.items.insert(newIndex, item);

    state = state.copyWith(sections: [...state.sections]);
  }

  // ------------------------------------------------------------
  // OCR / Analyse
  // ------------------------------------------------------------

  Future<void> analyzeIngredientsFromImage({
    required bool pickImageFromCamera,
  }) async {
    state = state.copyWith(isAnalyzing: true);

    final imageManager = ref.read(imageManagerProvider.notifier);
    final analysisNotifier = ref.read(recipeAnalysisProvider.notifier);

    if (pickImageFromCamera) {
      await imageManager.pickImageFromCamera(
        imageType: AnalysisImageType.ingredients,
      );
    } else {
      await imageManager.pickImageFromGallery(
        imageType: AnalysisImageType.ingredients,
      );
    }

    final image = ref.read(imageManagerProvider).ingredientsImage;
    if (image == null) {
      state = state.copyWith(isAnalyzing: false);
      return;
    }

    await analysisNotifier.analyzeImage(
      image: image,
      isIngredientImage: true,
    );

    final analysisState = ref.read(recipeAnalysisProvider);

    analysisState.when(
      data: (data) {
        final ingredients = data?.ingredients;
        if (ingredients == null) {
          state = state.copyWith(isAnalyzing: false);
          return;
        }

        // alten State aufräumen
        for (final section in state.sections) {
          for (final item in section.items) {
            item.dispose();
          }
        }

        state = state.copyWith(
          sections: [
            IngredientSectionForm(
              title: 'Zutaten',
              items:
                  ingredients.map(IngredientFormItem.fromIngredient).toList(),
            ),
          ],
          isAnalyzing: false,
        );
      },
      loading: () {},
      error: (_, __) {
        state = state.copyWith(isAnalyzing: false);
      },
    );
  }
}
