import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class CookbookPage extends StatelessWidget {
  const CookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Kochbuch",
        actionsButtons: [
          IconButton(
            onPressed: () => context.router.push(AddEditRecipeRoute()),
            icon: Icon(
              AppIcons.plus_1,
              size: 35,
            ),
          ),
        ],
      ),
      scaffoldBody: CookbookBody(),
    );
  }
}
