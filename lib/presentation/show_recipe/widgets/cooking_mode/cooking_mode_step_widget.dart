import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_widget.dart';
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
    final double pageMargin = 20;
    final Duration animationDuration = Duration(milliseconds: 200);
    final double borderRadius = 8;
    return Column(
      children: [
        CookingModeStepTitle(
          stepNumber: widget.stepNumber,
          recipeId: widget.recipeId,
          onAddTimer: () => setState(() => _isAddingTimer = true),
        ),
        CookingModeIngredientsList(
          isExpanded: widget.isExpanded,
          onExpandToggle: widget.onExpandToggle,
          pageMargin: pageMargin,
          animationDuration: animationDuration,
          borderRadius: borderRadius,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              children: [
                CookingModeIngredientsWidget(
                  ingredientSections: widget.ingredientSections,
                  isExpanded: widget.isExpanded,
                  pageMargin: pageMargin,
                  animationDuration: animationDuration,
                  borderRadius: borderRadius,
                ),
                CookingModeTimerWidget(
                  recipeId: widget.recipeId,
                  stepIndex: widget.stepNumber - 1,
                  pageMargin: pageMargin,
                  borderRadius: borderRadius,
                  forceShowPicker: _isAddingTimer,
                  onPickerClosed: () => setState(() => _isAddingTimer = false),
                ),
                CookingModeInstructions(
                  pageMargin: pageMargin,
                  instructionStep: widget.instructionStep,
                  borderRadius: borderRadius,
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
