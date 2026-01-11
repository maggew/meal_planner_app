import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_appbar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_bottom_navigation_bar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_overview.dart';

@RoutePage()
class ShowRecipePage extends StatefulWidget {
  final Recipe recipe;
  final Image image;
  const ShowRecipePage({super.key, required this.recipe, required this.image});

  @override
  State<ShowRecipePage> createState() => _ShowRecipePageState();
}

class _ShowRecipePageState extends State<ShowRecipePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
        scaffoldAppBar: ShowRecipeAppbar(recipe: widget.recipe),
        scaffoldBottomNavigationBar: ShowRecipeBottomNavigationBar(
          tabController: _tabController,
        ),
        scaffoldBody: TabBarView(
          controller: _tabController,
          children: [
            ShowRecipeOverview(
              recipe: widget.recipe,
              image: widget.image,
            ),
            ShowRecipeCookingMode(recipe: widget.recipe),
          ],
        ));
  }
}
