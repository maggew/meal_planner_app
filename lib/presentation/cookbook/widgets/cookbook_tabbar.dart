import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/constants/categories.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/presentation/cookbook/widgets/vertical_tabbar.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_category_tab.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_recipe_list.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/recipe/cookbook_initial_category_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

class CookbookTabbar extends ConsumerWidget {
  const CookbookTabbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(groupCategoriesProvider);
    final tabsPosition =
        ref.watch(userSettingsProvider.select((s) => s.tabPosition));
    final tabsLeft = tabsPosition == TabPosition.left;

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
      data: (categories) {
        final allCategories = categories.map((c) => c.id).toList();

        final (:categoryId, :generation) =
            ref.watch(cookbookInitialCategoryProvider);
        int initialIndex = 0;
        if (categoryId != null) {
          final idx = categories.indexWhere((c) => c.id == categoryId);
          if (idx != -1) initialIndex = idx;
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => ref.read(cookbookInitialCategoryProvider.notifier).clear());
        }

        return VerticalTabs(
          key: ValueKey(generation),
          initialIndex: initialIndex,
          disabledChangePageFromContentView: true,
          tabsWidth: 70,
          tabsPosition: tabsPosition,
          changePageDuration: AppDimensions.animationDuration,
          changePageCurve: Curves.easeInOutCubic,
          tabs: [
            ...categories.map(
              (category) => CookbookCategoryTab(
                name: category.name,
                iconWidget: Icon(
                  getCategoryIconData(category.name,
                      iconName: category.iconName),
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
                      image: AssetImage("assets/images/Rosi.png"),
                      height: 40,
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            )
          ],
          contents: [
            ...categories.map(
              (category) => CookbookRecipeList(
                  categoryId: category.id,
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
      },
    );
  }
}
