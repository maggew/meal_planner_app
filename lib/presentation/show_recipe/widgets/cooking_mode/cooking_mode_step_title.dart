import 'package:flutter/material.dart';

class CookingModeStepTitle extends StatelessWidget {
  final int stepNumber;
  const CookingModeStepTitle({super.key, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Schritt Nr. $stepNumber",
            style: themeData.textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
}
