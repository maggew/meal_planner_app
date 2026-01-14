import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/restructuring_of_ingredient_input/add_edit_recipe_igredient_listview_item.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

class AddEditRecipeIngredientsAlt extends ConsumerStatefulWidget {
  final List<Ingredient>? initialIngredients;
  const AddEditRecipeIngredientsAlt(
      {super.key, required this.initialIngredients});

  bool get isEditMode => initialIngredients != null;

  @override
  ConsumerState<AddEditRecipeIngredientsAlt> createState() =>
      _AddEditRecipeIngredientsAltState();
}

class _AddEditRecipeIngredientsAltState
    extends ConsumerState<AddEditRecipeIngredientsAlt> {
  final Map<int, DropdownController<Unit>> dropdownControllers = {};
  final Map<int, TextEditingController> amountControllers = {};
  final Map<int, TextEditingController> ingredientNameControllers = {};

  bool _isInitialized = false;

  DropdownController<Unit> _getOrCreateDropdownController(int index) {
    if (!dropdownControllers.containsKey(index)) {
      dropdownControllers[index] = DropdownController();
    }
    return dropdownControllers[index]!;
  }

  TextEditingController _getAmountController(int index, Ingredient ingredient) {
    if (!amountControllers.containsKey(index)) {
      amountControllers[index] = TextEditingController(
        text: ingredient.amount > 0 ? ingredient.amount.toString() : "",
      );
    }
    return amountControllers[index]!;
  }

  TextEditingController _getIngredientNameController(
      int index, Ingredient ingredient) {
    if (!ingredientNameControllers.containsKey(index)) {
      ingredientNameControllers[index] =
          TextEditingController(text: ingredient.name);
    }
    return ingredientNameControllers[index]!;
  }

  @override
  void dispose() {
    amountControllers.values.forEach((c) => c.dispose());
    ingredientNameControllers.values.forEach((c) => c.dispose());
    dropdownControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(ingredientsProvider.notifier);
      notifier.clear();

      if (widget.initialIngredients != null &&
          widget.initialIngredients!.isNotEmpty) {
        notifier.setIngredients(widget.initialIngredients!);
      } else {
        notifier.addIngredient();
      }

      setState(() {
        _isInitialized = true; // ← Jetzt erst rendern
      });
    });
  }

  void _clearAllControllers() {
    amountControllers.values.forEach((c) => c.dispose());
    ingredientNameControllers.values.forEach((c) => c.dispose());
    dropdownControllers.values.forEach((c) => c.dispose());
    amountControllers.clear();
    ingredientNameControllers.clear();
    dropdownControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(height: 300); // Platzhalter
    }

    final ingredients = ref.watch(ingredientsProvider);
    final List<CoolDropdownItem<Unit>> unitDropdownItems =
        getUnitDropdownItems();

    ref.listen(imageManagerProvider, (previous, next) {
      final image = next.ingredientsImage;
      if (image != null && image != previous?.ingredientsImage) {
        ref.read(recipeAnalysisProvider.notifier).analyzeImage(
              image: image,
              isIngredientImage: true,
            );
      }
    });

    ref.listen(recipeAnalysisProvider, (previous, next) {
      next.whenData((data) {
        if (data != null && data.ingredients != null) {
          ref
              .read(ingredientsProvider.notifier)
              .setIngredients(data.ingredients!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Zutaten erfolgreich analysiert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    });

    final isAnalyzing = ref.watch(recipeAnalysisProvider).isLoading &&
        ref.read(recipeAnalysisProvider.notifier).isLoadingIngredients;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Zutaten",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromCamera(
                    imageType: AnalysisImageType.ingredients);
              },
              icon: Icon(Icons.camera_alt_outlined),
            ),
            Gap(10),
            IconButton(
              onPressed: () {
                ref.read(imageManagerProvider.notifier).pickImageFromGallery(
                    imageType: AnalysisImageType.ingredients);
              },
              icon: Icon(Icons.folder_outlined),
            ),
          ],
        ),
        SizedBox(height: 10),
        LoadingOverlay(
          isLoading: isAnalyzing,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final Ingredient ingredient = ingredients[index];
                    return AddEditRecipeIgredientListviewItem(
                      index: index,
                      amountController: _getAmountController(index, ingredient),
                      ingredient: ingredient,
                      ingredientNameController:
                          _getIngredientNameController(index, ingredient),
                      unitDropdownItems: unitDropdownItems,
                      unitDropdownController:
                          _getOrCreateDropdownController(index),
                      onDelete: () {
                        ref
                            .read(ingredientsProvider.notifier)
                            .deleteIngredient(index);
                        _clearAllControllers();
                      },
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(ingredientsProvider.notifier).addIngredient();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Zutat hinzufügen'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
