import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:editable/editable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_ingredients.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_picture.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_recipe_name_textformfield.dart';
import 'package:meal_planner/services/providers/add_recipe_provider.dart';

class AddRecipeBody extends StatelessWidget {
  final DropdownController categoryDropdownController;
  final DropdownController portionDropdownController;
  final DropdownController unitDropdownController;
  final TextEditingController recipeNameController;
  final TextEditingController recipeInstructionsController;
  final WidgetRef ref;
  final GlobalKey<EditableState> ingredientTable;
  const AddRecipeBody({
    super.key,
    required this.recipeNameController,
    required this.recipeInstructionsController,
    required this.categoryDropdownController,
    required this.portionDropdownController,
    required this.unitDropdownController,
    required this.ref,
    required this.ingredientTable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddRecipeRecipeNameTextformfield(
                recipeNameController: recipeNameController),
            AddRecipeCategorySelection(
              categoryDropdownController: categoryDropdownController,
              ref: ref,
            ),
            SizedBox(height: 30),
            AddRecipePortionSelection(
              portionDropdownController: portionDropdownController,
              ref: ref,
            ),
            SizedBox(height: 30),
            AddRecipeIngredients(
              unitDropdownController: unitDropdownController,
              ref: ref,
            ),
            /*TextButton(
                      onPressed: () => _printTableData(),
                      child: Text('Show Data')),*/

            // alternative table (without editing)
            /* Column(
                    children: [
                      DataTable(
                        columns: [
                          DataColumn(label: Text('Zutat')),
                          DataColumn(label: Text('Anzahl')),
                          DataColumn(label: Text('Einheit')),
                        ],
                        rows: _rowList,
                        key: _ingredientTable,
                
                      ),
                
                
                      FloatingActionButton.small(
                        onPressed: () {
                          _addRow();
                        }, //
                        child: Text("+"),
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),*/
            //TextButton(onPressed: () => {}, child: Text('Show Data')),
            SizedBox(height: 30),
            AddRecipeInstructions(
              recipeInstructionsController: recipeInstructionsController,
            ),
            SizedBox(height: 30),
            AddRecipePicture(),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(130, 40),
                  ),
                  onPressed: () async {
                    final selectedCategory =
                        ref.watch(selectedCategoryProvider);
                    final selectedPortions =
                        ref.watch(selectedPortionsProvider);
                    print("Rezeptname: ${recipeNameController.text}");
                    print(
                        "Kategorie: ${selectedCategory}, Portionen: ${selectedPortions}");
                    print("Anleitungen: ${recipeInstructionsController.text}");
                    print("Zutaten:");
                    readData();
                    //List ingredients = readData();
                    //todo check if save was successful, else dont pop navigation

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
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List readData() {
    print(ingredientTable.currentState?.rows?.first);
    List editedRows = ingredientTable.currentState?.rows ?? [];
    editedRows.forEach((element) {
      element.removeWhere((key, value) => key == 'row');
    });
    return editedRows;
  }
}
