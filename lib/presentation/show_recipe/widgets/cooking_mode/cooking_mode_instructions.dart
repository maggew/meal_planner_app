import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';

class CookingModeInstructions extends StatelessWidget {
  final String instructionStep;
  const CookingModeInstructions({
    super.key,
    required this.instructionStep,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeData.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: Text(instructionStep),
    );
  }
}
