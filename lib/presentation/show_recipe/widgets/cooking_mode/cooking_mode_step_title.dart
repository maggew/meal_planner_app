import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';

class CookingModeStepTitle extends ConsumerWidget {
  final int stepNumber;
  final String recipeId;
  final VoidCallback onAddTimer;

  const CookingModeStepTitle({
    super.key,
    required this.stepNumber,
    required this.recipeId,
    required this.onAddTimer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final savedTimers = ref.watch(recipeTimersProvider(recipeId));
    final hasTimer = savedTimers.value?[stepNumber - 1] != null;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "Schritt Nr. $stepNumber",
            style: themeData.textTheme.displayMedium,
          ),
          if (!hasTimer)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onAddTimer,
                  icon: const Icon(Icons.add_alarm, size: 22),
                  color: Colors.deepOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
