import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';

class QuickAssignDialog extends ConsumerStatefulWidget {
  final Recipe recipe;

  const QuickAssignDialog({super.key, required this.recipe});

  @override
  ConsumerState<QuickAssignDialog> createState() => _QuickAssignDialogState();
}

class _QuickAssignDialogState extends ConsumerState<QuickAssignDialog> {
  DateTime _selectedDate = DateTime.now();
  MealType _selectedMealType = MealType.dinner;
  bool _isSaving = false;

  List<DateTime> get _nextSevenDays {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}.${date.month}.';
  }

  Future<void> _assign() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(mealPlanActionsProvider).addEntry(
            date: _selectedDate,
            mealType: _selectedMealType,
            recipeId: widget.recipe.id,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.recipe.name} eingeplant!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = _nextSevenDays;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Einplanen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                widget.recipe.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text('Tag', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final isSelected = day.year == _selectedDate.year &&
                        day.month == _selectedDate.month &&
                        day.day == _selectedDate.day;
                    return ChoiceChip(
                      label: Text(_formatDate(day)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedDate = day),
                      selectedColor: colorScheme.primaryContainer,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Mahlzeit', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: MealType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _selectedMealType == type,
                    onSelected: (_) => setState(() => _selectedMealType = type),
                    selectedColor: colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _assign,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadius),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Einplanen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
