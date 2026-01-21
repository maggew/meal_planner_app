import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class CookingModeIngredientsList extends StatelessWidget {
  final VoidCallback onExpandToggle;
  final bool isExpanded;
  final double pageMargin;
  final Duration animationDuration;
  final double borderRadius;
  const CookingModeIngredientsList({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.pageMargin,
    required this.animationDuration,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpandToggle,
      child: AnimatedContainer(
        duration: animationDuration,
        margin: EdgeInsets.symmetric(horizontal: pageMargin),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: isExpanded
              ? BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  topLeft: Radius.circular(borderRadius))
              : BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Text("Zutaten",
                    style: Theme.of(context).textTheme.bodyLargeEmphasis),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: animationDuration,
              child: Icon(Icons.expand_more),
            ),
          ],
        ),
      ),
    );
  }
}
