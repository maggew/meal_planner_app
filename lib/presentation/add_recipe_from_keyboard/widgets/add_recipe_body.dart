import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_button.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_category_selection.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_ingredients.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_picture.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_portion_selection.dart';
import 'package:meal_planner/presentation/add_recipe_from_keyboard/widgets/add_recipe_recipe_name_textformfield.dart';

class AddRecipeBody extends StatelessWidget {
  final DropdownController categoryDropdownController;
  final DropdownController portionDropdownController;
  final TextEditingController recipeNameController;
  final TextEditingController recipeInstructionsController;
  const AddRecipeBody({
    super.key,
    required this.recipeNameController,
    required this.recipeInstructionsController,
    required this.categoryDropdownController,
    required this.portionDropdownController,
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
            ),
            SizedBox(height: 30),
            AddRecipePortionSelection(
              portionDropdownController: portionDropdownController,
            ),
            SizedBox(height: 30),
            AddRecipeIngredients(),
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
            AddRecipeButton(
                recipeNameController: recipeNameController,
                recipeInstructionsController: recipeInstructionsController),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // List readData() {
  //   print(ingredientTable.currentState?.rows?.first);
  //   List editedRows = ingredientTable.currentState?.rows ?? [];
  //   editedRows.forEach((element) {
  //     element.removeWhere((key, value) => key == 'row');
  //   });
  //   return editedRows;
  // }
}
