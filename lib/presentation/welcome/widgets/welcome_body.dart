import 'package:flutter/material.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/caticorn.png'),
            height: 100,
          ),
          const SizedBox(height: 35),
          FittedBox(
            child: Text(
              "Willkommen zum",
              style: themeData.textTheme.displayLarge
                  ?.copyWith(color: themeData.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FittedBox(
            child: Text(
              "meal\nplanner",
              style: themeData.textTheme.displayLarge
                  ?.copyWith(color: themeData.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
          const Image(
            image: AssetImage('assets/images/avocado_light.png'),
            height: 200,
          ),
        ],
      ),
    );
  }
}
