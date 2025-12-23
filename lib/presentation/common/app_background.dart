import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final PreferredSizeWidget? scaffoldAppBar;
  final Widget? scaffoldBody;
  final Widget? scaffoldDrawer;
  final FloatingActionButton? scaffoldFloatingActionButton;
  final FloatingActionButtonLocation? scaffoldFloatingActionButtonLocation;
  const AppBackground({
    super.key,
    this.scaffoldDrawer,
    this.scaffoldAppBar,
    this.scaffoldBody,
    this.scaffoldFloatingActionButton,
    this.scaffoldFloatingActionButtonLocation,
  });

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
                  child: Image.asset(
                    'assets/images/background.png',
                  ),
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: (scaffoldAppBar != null) ? scaffoldAppBar : null,
          body: (scaffoldBody != null) ? scaffoldBody : null,
          drawer: (scaffoldDrawer != null) ? scaffoldDrawer : null,
          floatingActionButton: (scaffoldFloatingActionButton != null)
              ? scaffoldFloatingActionButton
              : null,
          floatingActionButtonLocation:
              (scaffoldFloatingActionButtonLocation != null)
                  ? scaffoldFloatingActionButtonLocation
                  : null,
          extendBodyBehindAppBar: false,
        )
      ],
    );
  }
}
