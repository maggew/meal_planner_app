import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_add_recipe_dialog.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_body.dart';

@RoutePage()
class CookbookPage extends StatelessWidget {
  const CookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
          title: "Kochbuch",
          hasActionButton: true,
          onActionPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) => CookbookAddRecipeDialog());
          }),
      scaffoldBody: CookbookBody(),
    );
  }
}
