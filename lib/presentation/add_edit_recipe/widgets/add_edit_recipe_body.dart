import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/data/model/scraped_recipe_data.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/recipe_extractor.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_button.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_ingredients_widget.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_picture.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_portion_selection.dart' show AddEditRecipePortionSelection, maxPortionsNumber;
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_recipe_name_textformfield.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/carb_tag_selection.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/carb_tag_selection_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class AddEditRecipeBody extends ConsumerStatefulWidget {
  final Recipe? existingRecipe;

  const AddEditRecipeBody({
    super.key,
    required this.existingRecipe,
  });

  @override
  ConsumerState<AddEditRecipeBody> createState() => AddEditRecipeBodyState();
}

class AddEditRecipeBodyState extends ConsumerState<AddEditRecipeBody> {
  late final TextEditingController _recipeNameController;
  late final TextEditingController _recipeInstructionsController;
  late final AddEditRecipeIngredientsProvider ingredientsProvider;

  @override
  void initState() {
    super.initState();
    _recipeNameController =
        TextEditingController(text: widget.existingRecipe?.name ?? '');
    _recipeInstructionsController =
        TextEditingController(text: widget.existingRecipe?.instructions ?? '');

    ingredientsProvider = addEditRecipeIngredientsProvider(
      widget.existingRecipe?.ingredientSections,
    );
    if (widget.existingRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Kategorie-Namen → IDs konvertieren für robuste Auswahl (unabhängig von Umbenennungen)
        final allCategories = ref.read(groupCategoriesProvider).value ?? [];
        final existingNames =
            widget.existingRecipe!.categories.map((n) => n).toSet();
        final categoryIds = allCategories
            .where((c) => existingNames.contains(c.name))
            .map((c) => c.id)
            .toList();
        ref.read(selectedCategoriesProvider.notifier).set(categoryIds);
        // setting intial portions
        ref
            .read(selectedPortionsProvider.notifier)
            .set(widget.existingRecipe!.portions);
        ref.read(carbTagSelectionProvider.notifier)
            .set(widget.existingRecipe!.carbTags);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(imageManagerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(imageManagerProvider.notifier).clearError();
      }
    });

    final showCarbTags = ref.watch(
      sessionProvider.select((s) => s.group?.settings.showCarbTags ?? true),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 25,
        children: [
          GlassCard(
            child: AddEditRecipeRecipeNameTextformfield(
              recipeNameController: _recipeNameController,
            ),
          ),
          GlassCard(
            child: AddEditRecipeCategorySelection(),
          ),
          GlassCard(
            child: AddEditRecipePortionSelection(),
          ),
          GlassCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AddEditRecipeIngredientsWidget(
              ingredientsProvider: ingredientsProvider,
            ),
          ),
          GlassCard(
            child: AddEditRecipeInstructions(
              recipeInstructionsController: _recipeInstructionsController,
            ),
          ),
          GlassCard(
            child: AddEditRecipePicture(
              existingImageUrl: widget.existingRecipe?.imageUrl,
            ),
          ),
          if (showCarbTags)
            GlassCard(
              child: CarbTagSelection(),
            ),
          AddEditRecipeButton(
            recipeNameController: _recipeNameController,
            recipeInstructionsController: _recipeInstructionsController,
            existingRecipe: widget.existingRecipe,
            ingredientsProvider: ingredientsProvider,
            isEditMode: widget.existingRecipe != null,
          ),
        ],
      ),
    );
  }

  void applyScrapedData(ScrapedRecipeData data) {
    if (data.name != null) _recipeNameController.text = data.name!;
    if (data.instructions != null) {
      _recipeInstructionsController.text = data.instructions!;
    }
    if (data.servings != null) {
      final clamped = data.servings!.clamp(1, maxPortionsNumber);
      ref.read(selectedPortionsProvider.notifier).set(clamped);
    }

    final sections = RecipeExtractor.processRawLines(data.rawIngredients);
    ref.read(ingredientsProvider.notifier).loadFromScraped(sections);

    if (data.localImagePath != null) {
      ref.read(imageManagerProvider.notifier).setPhoto(File(data.localImagePath!));
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _recipeInstructionsController.dispose();
    super.dispose();
  }
}
