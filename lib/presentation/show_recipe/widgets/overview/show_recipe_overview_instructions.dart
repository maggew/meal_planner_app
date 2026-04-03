import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/recipe_link_text.dart';

class ShowRecipeOverviewInstructions extends StatelessWidget {
  final Recipe recipe;
  const ShowRecipeOverviewInstructions({super.key, required this.recipe});

  /// Parse instructions into (stepNumber, text) pairs.
  /// Returns null if no numbered pattern is found.
  List<(int, String)>? _parseNumberedSteps(String instructions) {
    final stepRegex = RegExp(r'(?:^|\n)\s*(\d+)\.\s');
    final matches = stepRegex.allMatches(instructions).toList();

    if (matches.isEmpty) return null;

    final steps = <(int, String)>[];
    for (int i = 0; i < matches.length; i++) {
      final number = int.parse(matches[i].group(1)!);
      final start = matches[i].end;
      final end =
          i + 1 < matches.length ? matches[i + 1].start : instructions.length;
      final text = instructions.substring(start, end).trim();
      if (text.isNotEmpty) {
        steps.add((number, text));
      }
    }

    return steps.isEmpty ? null : steps;
  }

  @override
  Widget build(BuildContext context) {
    final instructions = recipe.instructions.trim();

    if (instructions.isEmpty) return const SizedBox.shrink();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final steps = _parseNumberedSteps(instructions);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: steps != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final (number, text) = entry.value;
                final isLast = index == steps.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 65,
                          child: Text(
                            '$number',
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.25),
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: RecipeLinkText(text, style: textTheme.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) Divider(),
                  ],
                );
              }).toList(),
            )
          : RecipeLinkText(instructions, style: textTheme.bodyMedium),
    );
  }
}
