import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_widget.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_instructions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_title.dart';

class CookingModeStepWidget extends StatefulWidget {
  final String instructionStep;
  final int stepNumber;
  final List<Ingredient> ingredients;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const CookingModeStepWidget({
    super.key,
    required this.instructionStep,
    required this.stepNumber,
    required this.ingredients,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  State<CookingModeStepWidget> createState() => _CookingModeStepWidgetState();
}

class _CookingModeStepWidgetState extends State<CookingModeStepWidget> {
  @override
  Widget build(BuildContext context) {
    final double pageMargin = 20;
    final Duration animationDuration = Duration(milliseconds: 200);
    final double borderRadius = 8;
    return Column(
      children: [
        CookingModeStepTitle(stepNumber: widget.stepNumber),
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
                  ingredients: widget.ingredients,
                  isExpanded: widget.isExpanded,
                  pageMargin: pageMargin,
                  animationDuration: animationDuration,
                  borderRadius: borderRadius,
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
