import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  static const _icons = [
    AppIcons.calendar_1,
    AppIcons.recipe_book,
    AppIcons.shopping_list,
    AppIcons.cat_1,
  ];

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      lazyLoad: false,
      transitionBuilder: (context, child, animation) => child,
      routes: const [
        DetailedWeekplanRoute(),
        CookbookRoute(),
        ShoppingListRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.surface,
          body: child,
          bottomNavigationBar: Container(
            color: colors.surfaceContainerHigh,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_icons.length, (index) {
                    final isSelected = tabsRouter.activeIndex == index;
                    return GestureDetector(
                      onTap: () => tabsRouter.setActiveIndex(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: AppDimensions.animationDuration,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.surface : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected
                              ? colors.secondary
                              : colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
