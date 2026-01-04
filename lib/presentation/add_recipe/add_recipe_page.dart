import 'dart:core';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/add_recipe/widgets/add_recipe_body.dart';
import 'package:meal_planner/presentation/common/app_background.dart';

@RoutePage()
class AddRecipePage extends ConsumerWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      scaffoldAppBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.black,
            ),
            onPressed: () {
              context.router.pop();
            }),
        title: Text(
          "Neues Rezept erstellen",
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      scaffoldBody: AddRecipeBody(),
    );
  }
}
