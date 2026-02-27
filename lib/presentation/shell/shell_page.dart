import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/shell/widgets/shell_bottom_nav_bar.dart';

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
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colors.surface,
          body: child,
          bottomNavigationBar: ShellBottomNavBar(
            activeIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}
