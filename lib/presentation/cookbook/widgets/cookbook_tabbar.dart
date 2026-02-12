// lib/presentation/cookbook/widgets/cookbook_tabbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/common/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/presentation/cookbook/widgets/default_category_tabs.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class CookbookTabbar extends ConsumerWidget {
  const CookbookTabbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = categoryNames.map((c) => c.toLowerCase()).toList();

    final session = ref.read(sessionProvider);
    final tabPosition = session.settings!.tabPosition == TabPosition.left
        ? TextDirection.ltr
        : TextDirection.rtl;

    return VerticalTabs(
      disabledChangePageFromContentView: true,
      tabsElevation: 50,
      selectedTabBackgroundColor: Colors.lightGreen[100]!,
      indicatorColor: Colors.pink[100]!,
      backgroundColor: Colors.transparent,
      tabsWidth: 100,
      direction: tabPosition,
      tabs: getDefaultCategoryTabs(),
      contents: [
        ..._getCategoryLists(allCategories: allCategories, tabsLeft: true),
        Container(
          child: Center(
            child: Text("Hier kommt noch was"),
          ),
        ),
      ],
    );
  }
}

List<Widget> _getCategoryLists(
    {required List<String> allCategories, required bool tabsLeft}) {
  final margin =
      tabsLeft ? EdgeInsets.only(left: 10) : EdgeInsets.only(right: 10);
  List<Widget> categoryLists = [];
  for (String category in categoryNames) {
    categoryLists.add(
      Container(
        margin: margin,
        child: CookbookRecipeList(
          category: category.toLowerCase(),
          allCategories: allCategories,
        ),
      ),
    );
  }
  return categoryLists;
}
