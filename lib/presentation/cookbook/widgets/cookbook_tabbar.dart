import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_category_tab.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

class CookbookTabbar extends ConsumerWidget {
  const CookbookTabbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = categoryNames.map((c) => c.toLowerCase()).toList();

    final tabsPosition =
        ref.watch(userSettingsProvider.select((s) => s.tabPosition));
    final tabsLeft = tabsPosition == TabPosition.left;

    return VerticalTabs(
      disabledChangePageFromContentView: true,
      tabsElevation: 50,
      tabsWidth: 100,
      tabsPosition: tabsPosition,
      tabs: [
        ...categoryNames.map(
          (category) => CookbookCategoryTab(
            name: category,
            iconWidget: Icon(
              getCategoryIconData(category),
              size: 30,
            ),
          ),
        ),
        Tab(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 8),
                Image(
                  image: AssetImage("assets/images/caticorn.png"),
                  height: 40,
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        )
      ],
      contents: [
        ...categoryNames.map(
          (category) => CookbookRecipeList(
              category: category,
              allCategories: allCategories,
              tabsLeft: tabsLeft),
        ),
        Container(
          child: Center(
            child: Text("Hier kommt noch was"),
          ),
        ),
      ],
    );
  }
}
