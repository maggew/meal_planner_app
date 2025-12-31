import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/image_path_provider.dart';

class AddRecipeButton extends ConsumerStatefulWidget {
  final TextEditingController recipeNameController;
  final TextEditingController recipeInstructionsController;
  const AddRecipeButton({
    super.key,
    required this.recipeNameController,
    required this.recipeInstructionsController,
  });

  @override
  ConsumerState<AddRecipeButton> createState() => _AddRecipeButtonState();
}

class _AddRecipeButtonState extends ConsumerState<AddRecipeButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(130, 40),
          ),
          onPressed: () async {
            final selectedCategory = ref.read(selectedCategoryProvider);
            final selectedPortions = ref.read(selectedPortionsProvider);
            final ingredients = ref.read(ingredientsProvider);
            final image = ref.read(imagePathProvider);
            print("Rezeptname: ${widget.recipeNameController.text}");
            print(
                "Kategorie: ${selectedCategory}, Portionen: ${selectedPortions}");
            print("Anleitungen: ${widget.recipeInstructionsController.text}");
            print("Zutaten:");
            for (Ingredient ingredient in ingredients) {
              print(
                  "${ingredient.name}\t${ingredient.amount} ${ingredient.unit.displayName}");
            }
            print("Image: $image");

            final validation = ref.validateRecipe(
              name: widget.recipeNameController.text,
              instructions: widget.recipeInstructionsController.text,
            );

            if (!validation.isValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(validation.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // _resetForm(
            //   recipeNameController: widget.recipeNameController,
            //   recipeInstructionsController: widget.recipeInstructionsController,
            // );

            // if (_formCheck.currentState.validate() &&
            //     ingredients.isNotEmpty) {
            //   if (_iconPath != "" || _iconPath != null) {
            //     await Database()
            //         .uploadRecipeImageToFirebase(
            //             context, imageFile)
            //         .then((url) {
            //       Database().saveNewRecipe(
            //           recipeName,
            //           translateCategory(category),
            //           portions,
            //           ingredients,
            //           instruction,
            //           url);
            //     });
            //   } else {
            //     Database().saveNewRecipe(
            //         recipeName,
            //         translateCategory(category),
            //         portions,
            //         ingredients,
            //         instruction,
            //         "");
            //   }
            //
            //   Navigator.pushNamedAndRemoveUntil(
            //       context, '/cookbook', (r) => false);
            // } else if (ingredients.isEmpty) {
            //   _scrollToTop();
            //   Fluttertoast.showToast(
            //     timeInSecForIosWeb: 5,
            //     msg: "Bitte Zutaten hinzufügen",
            //   );
            //   return null;
            // } else {
            //   _scrollToTop();
            //   return null;
            // }
          },
          child: Text(
            "Speichern",
          ),
        ),
      ],
    );
  }

  void _resetForm({
    required TextEditingController recipeNameController,
    required TextEditingController recipeInstructionsController,
  }) {
    ref.read(ingredientsProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).state = DEFAULT_CATEGORY;
    ref.read(selectedPortionsProvider.notifier).state = DEFAULT_PORTIONS;
    ref.read(imagePathProvider.notifier).clear();
    recipeNameController.clear();
    recipeInstructionsController.clear();
  }
}
