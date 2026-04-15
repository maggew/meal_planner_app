import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/cooking_mini_bar.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/shell/widgets/shell_bottom_nav_bar.dart';
import 'package:meal_planner/presentation/shopping_list/widgets/shopping_list_input.dart';

@RoutePage()
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage>
    with SingleTickerProviderStateMixin {
  int _activeIndex = 1;
  DateTime? _lastBackPress;
  late final AnimationController _inputController;
  late final CurvedAnimation _inputCurve;

  @override
  void initState() {
    super.initState();
    _inputController = AnimationController(
      duration: AppDimensions.animationDuration,
      vsync: this,
    );
    _inputCurve = CurvedAnimation(
      parent: _inputController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _inputCurve.dispose();
    _inputController.dispose();
    super.dispose();
  }

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
            body: Stack(
              children: [
                child,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CookingMiniBar(),
                      SizeTransition(
                        sizeFactor: _inputCurve,
                        axisAlignment: 1.0,
                        child: const ShoppingListInput(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ShellBottomNavBar(
              activeIndex: _activeIndex,
              onTap: (index) {
                if (_activeIndex == 2 && index != 2) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
                setState(() => _activeIndex = index);
                tabsRouter.setActiveIndex(index);
                if (index == 2) {
                  _inputController.forward();
                } else {
                  _inputController.reverse();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
