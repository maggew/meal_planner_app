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
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.white,
            child: Opacity(
              opacity: 0.7,
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
          appBar: (scaffoldAppBar != null) ? scaffoldAppBar : null,
          body: (scaffoldBody != null) ? scaffoldBody : null,
          drawer: BurgerMenu(),
          floatingActionButton: (scaffoldFloatingActionButton != null)
              ? scaffoldFloatingActionButton
              : null,
          floatingActionButtonLocation:
              (scaffoldFloatingActionButtonLocation != null)
                  ? scaffoldFloatingActionButtonLocation
                  : null,
          extendBodyBehindAppBar: false,
          bottomNavigationBar: (scaffoldBottomNavigationBar != null)
              ? scaffoldBottomNavigationBar
              : null,
        )
      ],
    );
  }
}
