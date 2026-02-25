import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailes_weekplan/widgets/weekplan_meal_card.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';

class WeekplanDayMealsSection extends ConsumerWidget {
  final DateTime selectedDay;

  const WeekplanDayMealsSection({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanStreamProvider(selectedDay));

    return entriesAsync.when(
      data: (entries) => Column(
        children: MealType.values.map((type) {
          final entry =
              entries.where((e) => e.mealType == type).firstOrNull;
          return WeekplanMealCard(
            mealType: type,
            entry: entry,
            selectedDay: selectedDay,
          );
        }).toList(),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
