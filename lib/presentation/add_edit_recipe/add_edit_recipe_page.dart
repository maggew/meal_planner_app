import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_body.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/recipe_url_import_sheet.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';

@RoutePage()
class AddEditRecipePage extends StatefulWidget {
  final Recipe? existingRecipe;

  const AddEditRecipePage({super.key, this.existingRecipe});

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _bodyKey = GlobalKey<AddEditRecipeBodyState>();

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.existingRecipe != null;
    return AppBackground(
      applyScreenPadding: true,
      scaffoldAppBar: CommonAppbar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => context.router.pop(),
        ),
        title: isEditMode ? "Rezept bearbeiten" : "Neues Rezept erstellen",
        actionsButtons: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Von URL importieren',
            onPressed: () => showRecipeUrlImportSheet(
              context,
              (data) => _bodyKey.currentState?.applyScrapedData(data),
            ),
          ),
        ],
      ),
      scaffoldBody: AddEditRecipeBody(
        key: _bodyKey,
        existingRecipe: widget.existingRecipe,
      ),
    );
  }
}
