import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/shell/widgets/shell_bottom_nav_bar.dart';

@RoutePage()
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  DateTime? _lastBackPress;

  void _handleBack(BuildContext innerContext) {
    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) <= const Duration(seconds: 3)) {
      if (Platform.isAndroid) SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(innerContext).showSnackBar(
      const SnackBar(
        content: Text('Nochmal zurück drücken, um die App zu verlassen'),
        duration: Duration(seconds: 3),
      ),
    );
  }

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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(context);
          },
          child: Scaffold(
            backgroundColor: colors.surface,
            body: child,
            bottomNavigationBar: ShellBottomNavBar(
              activeIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
            ),
          ),
        );
      },
    );
  }
}
