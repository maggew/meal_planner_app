import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class CookingModeIngredientsWidget extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool isExpanded;
  final double pageMargin;
  final Duration animationDuration;
  final double borderRadius;
  const CookingModeIngredientsWidget({
    super.key,
    required this.ingredients,
    required this.isExpanded,
    required this.pageMargin,
    required this.animationDuration,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // Expandierbarer Inhalt
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Container(
            margin: EdgeInsetsGeometry.symmetric(horizontal: pageMargin),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius))),
            padding: EdgeInsets.all(10),
            child: Text.rich(
              style: textTheme.bodyMedium,
              TextSpan(
                children: ingredients.expand<TextSpan>((ing) {
                  final index = ingredients.indexOf(ing);
                  return [
                    if (index != 0) const TextSpan(text: ", "),
                    ...ing.toInlineTextSpans(
                      nameStyle: textTheme.bodyMediumEmphasis,
                    ),
                  ];
                }).toList(),
              ),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: animationDuration,
        ),
      ],
    );
  }
}
