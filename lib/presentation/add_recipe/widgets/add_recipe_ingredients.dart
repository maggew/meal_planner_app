import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_ingredient_row.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/add_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_analysis_provider.dart';

class AddRecipeIngredients extends ConsumerStatefulWidget {
  const AddRecipeIngredients({
    super.key,
  });
  @override
  ConsumerState<AddRecipeIngredients> createState() => _AddRecipeIngredients();
}

class _AddRecipeIngredients extends ConsumerState<AddRecipeIngredients> {
  final Map<int, DropdownController<Unit>> dropdownControllers = {};
  final Map<int, TextEditingController> amountControllers = {};
  final Map<int, TextEditingController> ingredientNameControllers = {};

  DropdownController<Unit> _getOrCreateDropdownController(int index) {
    if (!dropdownControllers.containsKey(index)) {
      dropdownControllers[index] = DropdownController();
    }
    return dropdownControllers[index]!;
  }

  TextEditingController _getAmountController(int index) {
    if (!amountControllers.containsKey(index)) {
      amountControllers[index] = TextEditingController(
        text: '',
      );
    }
    return amountControllers[index]!;
  }

  TextEditingController _getIngredientNameController(int index) {
    if (!ingredientNameControllers.containsKey(index)) {
      ingredientNameControllers[index] = TextEditingController(text: null);
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
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientsProvider);

    if (ingredients.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ingredientsProvider.notifier).addIngredient();
      });
    }
    final List<CoolDropdownItem<Unit>> unitDropdownItems =
        getUnitDropdownItems();

    // Reagiere auf neues Analyse-Bild
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
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.5),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: DataTable2(
                    horizontalMargin: 10,
                    dividerThickness: 2,
                    columnSpacing: 12,
                    isVerticalScrollBarVisible: true,
                    columns: [
                      DataColumn2(
                        label: Text('Zutat'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Menge'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Einheit'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text(''),
                        size: ColumnSize.S,
                      ),
                    ],
                    rows: ingredients.asMap().entries.map((entry) {
                      int index = entry.key;
                      Ingredient ingredient = entry.value;
                      return buildIngredientRow(
                        index: index,
                        ingredient: ingredient,
                        unitDropdownItems: unitDropdownItems,
                        ref: ref,
                        unitDropdownController:
                            _getOrCreateDropdownController(index),
                        dropdownControllerMap: dropdownControllers,
                        amountController: _getAmountController(index),
                        amountControllerMap: amountControllers,
                        ingredientNameController:
                            _getIngredientNameController(index),
                        ingredientNameControllerMap: ingredientNameControllers,
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(ingredientsProvider.notifier).addIngredient();
                      },
                      icon: Icon(Icons.add),
                      label: Text('Zutat hinzufügen'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<CoolDropdownItem<Unit>> getUnitDropdownItems() {
  List<CoolDropdownItem<Unit>> out = [];
  for (Unit unit in Unit.values) {
    out.add(CoolDropdownItem(label: unit.displayName, value: unit));
  }
  return out;
}
