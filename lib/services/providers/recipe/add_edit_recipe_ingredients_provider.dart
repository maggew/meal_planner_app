import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_section_form.dart';
import 'package:meal_planner/presentation/add_edit_recipe/state/ingredients_state.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/flat_list_item.dart';
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
        items: [],
        isEditable: true,
        shouldRequestFocus: true,
      ),
    );

    state = state.copyWith(sections: [...state.sections]);
  }

  void removeSection(int sectionIndex) {
    if (sectionIndex == 0) return;

    final List<IngredientFormItem> ingredientForms =
        state.sections[sectionIndex].items;

    state.sections[sectionIndex - 1].items.addAll(ingredientForms);

    final section = state.sections.removeAt(sectionIndex);
    section.dispose();
    state = state.copyWith(sections: [...state.sections]);
  }

  void editSectionTitle(int sectionIndex) {
    state.sections[sectionIndex].isEditable = true;
    state.sections[sectionIndex].shouldRequestFocus = true;
    state = state.copyWith(sections: [...state.sections]);
  }

  void confirmSectionTitle(int sectionIndex) {
    if (state.sections[sectionIndex].titleController.text.trim().isEmpty) {
      state.sections[sectionIndex].titleController.text = 'Zutaten';
    }

    state.sections[sectionIndex].isEditable = false;
    state.sections[sectionIndex].shouldRequestFocus = false;
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

  void deleteIngredient(int flatIndex) {
    final mapping = _getFlatMapping(flatIndex: flatIndex);
    final section = state.sections[mapping.sectionIndex];
    final item = section.items.removeAt(mapping.itemIndex);

    item.dispose();

    state = state.copyWith(sections: [...state.sections]);
  }

  void changeUnit({
    required int flatIndex,
    required Unit? unit,
  }) {
    final mapping = _getFlatMapping(flatIndex: flatIndex);
    final section = state.sections[mapping.sectionIndex];
    section.items[mapping.itemIndex].unit = unit;

    state = state.copyWith(sections: [...state.sections]);
  }

  void confirmIngredient(int flatIndex) {
    final mapping = _getFlatMapping(flatIndex: flatIndex);
    final section = state.sections[mapping.sectionIndex];
    final item = section.items[mapping.itemIndex];

    // Daten aus Controllern holen
    final name = item.nameController.text.trim();
    final amount = item.amountController.text.trim();

    // Ingredient mit den neuen Daten aktualisieren
    item.ingredient = item.ingredient.copyWith(
      name: name,
      amount: amount,
      unit: item.unit,
    );

    // Edit-Modus beenden
    item.isEditable = false;

    // State neu setzen
    state = state.copyWith(sections: [...state.sections]);
  }

  void editIngredient(int flatIndex) {
    final mapping = _getFlatMapping(flatIndex: flatIndex);
    final section = state.sections[mapping.sectionIndex];
    final item = section.items[mapping.itemIndex];

    // Edit-Modus aktivieren
    item.isEditable = true;

    // State neu setzen
    state = state.copyWith(sections: [...state.sections]);
  }

  void reorderIngredient({
    required int oldIndex,
    required int newIndex,
    required List<FlatListItem> flatItems,
  }) {
    final oldItem = flatItems[oldIndex];

    if (oldItem.type != FlatListItemType.ingredient) {
      return;
    }

    if (newIndex <= 0) {
      moveIngredient(
        fromSection: oldItem.sectionIndex,
        fromItem: oldItem.itemIndex!,
        toSection: 0,
        toItem: 0,
      );
      return;
    }

    // Wenn ans Ende gezogen wird, füge am Ende der letzten Section ein
    if (newIndex >= flatItems.length) {
      final lastSection = state.sections.length - 1;
      final lastItemIndex = state.sections[lastSection].items.length;
      moveIngredient(
        fromSection: oldItem.sectionIndex,
        fromItem: oldItem.itemIndex!,
        toSection: lastSection,
        toItem: lastItemIndex,
      );
      return;
    }

    int adjustedNewIndex = newIndex;

    if (oldIndex < newIndex) {
      adjustedNewIndex -= 1;
    }

    final newItem = flatItems[adjustedNewIndex];

    if (newItem.type == FlatListItemType.ingredient) {
      int targetItemIndex = newItem.itemIndex!;

      if (oldItem.sectionIndex == newItem.sectionIndex && oldIndex < newIndex) {
      } else if (oldItem.sectionIndex != newItem.sectionIndex &&
          oldIndex < newIndex) {
        targetItemIndex = newItem.itemIndex! + 1;
      }

      moveIngredient(
        fromSection: oldItem.sectionIndex,
        fromItem: oldItem.itemIndex!,
        toSection: newItem.sectionIndex,
        toItem: targetItemIndex,
      );
      return;
    }

    if (newItem.type == FlatListItemType.header) {
      if (oldIndex < newIndex) {
        moveIngredient(
          fromSection: oldItem.sectionIndex,
          fromItem: oldItem.itemIndex!,
          toSection: newItem.sectionIndex,
          toItem: 0,
        );
      } else {
        if (newItem.sectionIndex > 0) {
          final prevSection = newItem.sectionIndex - 1;
          final lastItemIndex = state.sections[prevSection].items.length;
          moveIngredient(
            fromSection: oldItem.sectionIndex,
            fromItem: oldItem.itemIndex!,
            toSection: prevSection,
            toItem: lastItemIndex,
          );
        }
      }
      return;
    }

    if (newItem.type == FlatListItemType.addButton) {
      final targetSection = newItem.sectionIndex;
      final lastItemIndex = state.sections[targetSection].items.length;

      moveIngredient(
        fromSection: oldItem.sectionIndex,
        fromItem: oldItem.itemIndex!,
        toSection: targetSection,
        toItem: lastItemIndex,
      );
      return;
    }

    print('No valid target found, aborting');
  }

  void moveIngredient({
    required int fromSection,
    required int fromItem,
    required int toSection,
    required int toItem,
  }) {
    // move inside a section
    if (fromSection == toSection) {
      _moveIngredientInsideSection(
          sectionIndex: fromSection, oldIndex: fromItem, newIndex: toItem);
      return;
    }

    // remove item from old section
    final item = state.sections[fromSection].items.removeAt(fromItem);

    // put item in new section
    state.sections[toSection].items.insert(toItem, item);

    // State aktualisieren
    state = state.copyWith(sections: [...state.sections]);
  }

  void _moveIngredientInsideSection(
      {required int sectionIndex,
      required int oldIndex,
      required int newIndex}) {
    final section = state.sections[sectionIndex];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

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
        final ingredientSections = data?.ingredientSections;
        if (ingredientSections == null) {
          state = state.copyWith(isAnalyzing: false);
          return;
        }

        // alten State aufräumen
        for (final section in state.sections) {
          for (final item in section.items) {
            item.dispose();
          }
        }

        final List<IngredientSectionForm> list = [];
        for (final section in ingredientSections) {
          list.add(IngredientSectionForm(
              title: section.title,
              items: section.ingredients
                  .map(IngredientFormItem.fromIngredient)
                  .toList()));
        }

        state = state.copyWith(
          sections: list,
          isAnalyzing: false,
        );
      },
      loading: () {},
      error: (_, __) {
        state = state.copyWith(isAnalyzing: false);
      },
    );
  }

  ({int sectionIndex, int itemIndex}) _getFlatMapping(
      {required int flatIndex}) {
    int currentIndex = 0;

    for (int sectionIdx = 0; sectionIdx < state.sections.length; sectionIdx++) {
      final section = state.sections[sectionIdx];

      // Section Header überspringen
      currentIndex++;

      // Ingredients durchgehen
      for (int itemIdx = 0; itemIdx < section.items.length; itemIdx++) {
        if (currentIndex == flatIndex) {
          return (sectionIndex: sectionIdx, itemIndex: itemIdx);
        }
        currentIndex++;
      }

      // Add Button überspringen
      currentIndex++;
    }

    throw RangeError('Flat index $flatIndex out of bounds');
  }
}
