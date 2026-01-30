import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class CookingModeIngredientsWidget extends StatelessWidget {
  final List<IngredientSection> ingredientSections;
  final bool isExpanded;
  final double pageMargin;
  final Duration animationDuration;
  final double borderRadius;
  const CookingModeIngredientsWidget({
    super.key,
    required this.ingredientSections,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...ingredientSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Text(section.title),
                        const SizedBox(height: 6),
                        // Section ingredients
                        Text.rich(
                          TextSpan(
                            style: textTheme.bodyMedium,
                            children: section.ingredients
                                .asMap()
                                .entries
                                .expand<TextSpan>((entry) {
                              final index = entry.key;
                              final ing = entry.value;

                              return [
                                if (index != 0) const TextSpan(text: ", "),
                                ...ing.toInlineTextSpans(
                                  nameStyle: textTheme.bodyMediumEmphasis,
                                ),
                              ];
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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
