import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';

class CookingModeIngredientsList extends StatefulWidget {
  final List<IngredientSection> ingredientSections;
  final VoidCallback onExpandToggle;
  final bool isExpanded;

  const CookingModeIngredientsList({
    super.key,
    required this.ingredientSections,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  State<CookingModeIngredientsList> createState() =>
      _CookingModeIngredientsListState();
}

class _CookingModeIngredientsListState
    extends State<CookingModeIngredientsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle-Button
        GestureDetector(
          onTap: widget.onExpandToggle,
          child: AnimatedContainer(
            duration: AppDimensions.animationDuration,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: themeData.colorScheme.primary,
              borderRadius: widget.isExpanded
                  ? BorderRadius.only(
                      topRight: Radius.circular(AppDimensions.borderRadius),
                      topLeft: Radius.circular(AppDimensions.borderRadius),
                    )
                  : BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Zutaten",
                      style: themeData.textTheme.bodyLargeEmphasis?.copyWith(
                        color: themeData.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0,
                  duration: AppDimensions.animationDuration,
                  child: Icon(
                    Icons.expand_more,
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandierbarer Inhalt mit MaxHeight
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeData.colorScheme.primaryContainer
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimensions.borderRadius),
                  bottomRight: Radius.circular(AppDimensions.borderRadius),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.ingredientSections.map((section) {
                      bool isLastSection = section ==
                          widget.ingredientSections[
                              widget.ingredientSections.length - 1];
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text(section.title),
                            Text.rich(
                              TextSpan(
                                style: themeData.textTheme.bodyMedium,
                                children: section.ingredients
                                    .asMap()
                                    .entries
                                    .expand<TextSpan>((entry) {
                                  final index = entry.key;
                                  final ing = entry.value;
                                  return [
                                    if (index != 0)
                                      TextSpan(
                                        text: "  \u2022  ", // this char: •
                                      ),
                                    ...ing.toInlineTextSpans(
                                      nameStyle: themeData
                                          .textTheme.bodyMediumEmphasis,
                                    ),
                                  ];
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 12),
                            if (!isLastSection) ...[
                              Divider(),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: AppDimensions.animationDuration,
        ),
      ],
    );
  }
}
