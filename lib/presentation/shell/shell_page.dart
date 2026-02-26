import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

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
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(AppIcons.calendar_1),
                label: 'Essensplan',
              ),
              NavigationDestination(
                icon: Icon(AppIcons.recipe_book),
                label: 'Kochbuch',
              ),
              NavigationDestination(
                icon: Icon(AppIcons.shopping_list),
                label: 'Einkaufsliste',
              ),
              NavigationDestination(
                icon: Icon(AppIcons.cat_1),
                label: 'Mein Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
