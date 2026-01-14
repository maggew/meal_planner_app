import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_widget.dart';
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
    return Column(
      children: [
        CookingModeStepTitle(stepNumber: widget.stepNumber),
        GestureDetector(
          onTap: widget.onExpandToggle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.amber,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Zutaten", style: TextStyle(fontWeight: FontWeight.bold)),
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
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
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                  child: Text(widget.instructionStep),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
