import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/burger_menu/burger_menu.dart';

class AppBackground extends StatelessWidget {
  final PreferredSizeWidget? scaffoldAppBar;
  final Widget? scaffoldBody;
  final FloatingActionButton? scaffoldFloatingActionButton;
  final FloatingActionButtonLocation? scaffoldFloatingActionButtonLocation;
  final Widget? scaffoldBottomNavigationBar;
  const AppBackground({
    super.key,
    this.scaffoldAppBar,
    this.scaffoldBody,
    this.scaffoldFloatingActionButton,
    this.scaffoldFloatingActionButtonLocation,
    this.scaffoldBottomNavigationBar,
  });

  static final _backgroundImage = Image.asset(
    'assets/images/background.png',
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            child: ColorFiltered(
              colorFilter: isDark
                  ? const ColorFilter.matrix(<double>[
                      0.12, 0.12, 0.12, 0, 0, // Red
                      0.14, 0.18, 0.14, 0, 0, // Green
                      0.12, 0.12, 0.12, 0, 0, // Blue
                      0, 0, 0, 1, 0,
                    ])
                  : const ColorFilter.matrix(<double>[
                      1, 0, 0, 0, 0, // Red
                      0, 1, 0, 0, 0, // Green
                      0, 0, 1, 0, 0, // Blue
                      0, 0, 0, 0.7, 0,
                    ]),
              child: RotatedBox(
                quarterTurns: 3,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: _backgroundImage,
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: scaffoldAppBar,
          body: scaffoldBody,
          drawer: BurgerMenu(),
          floatingActionButton: scaffoldFloatingActionButton,
          floatingActionButtonLocation: scaffoldFloatingActionButtonLocation,
          extendBodyBehindAppBar: false,
          bottomNavigationBar: scaffoldBottomNavigationBar,
        )
      ],
    );
  }
}
