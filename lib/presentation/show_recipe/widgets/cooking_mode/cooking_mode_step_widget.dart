import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_instructions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_title.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_timer_widget.dart';

class CookingModeStepWidget extends StatefulWidget {
  final String recipeId;
  final String instructionStep;
  final int stepNumber;
  final List<IngredientSection> ingredientSections;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const CookingModeStepWidget({
    super.key,
    required this.recipeId,
    required this.instructionStep,
    required this.stepNumber,
    required this.ingredientSections,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  State<CookingModeStepWidget> createState() => _CookingModeStepWidgetState();
}

class _CookingModeStepWidgetState extends State<CookingModeStepWidget> {
  bool _isAddingTimer = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        CookingModeStepTitle(
          stepNumber: widget.stepNumber,
          recipeId: widget.recipeId,
          onAddTimer: () => setState(() => _isAddingTimer = true),
        ),
        CookingModeTimerWidget(
          recipeId: widget.recipeId,
          stepIndex: widget.stepNumber - 1,
          forceShowPicker: _isAddingTimer,
          onPickerClosed: () => setState(() => _isAddingTimer = false),
        ),
        CookingModeIngredientsList(
          isExpanded: widget.isExpanded,
          onExpandToggle: widget.onExpandToggle,
          ingredientSections: widget.ingredientSections,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              children: [
                CookingModeInstructions(
                  instructionStep: widget.instructionStep,
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
