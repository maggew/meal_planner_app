import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/extensions/ingredient_inline_text_extenstion.dart';
import 'package:meal_planner/presentation/common/extensions/text_theme_extensions.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/timer/cooking_mode_timer_picker_sheet.dart';
import 'package:meal_planner/services/providers/recipe/linked_recipe_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/recipe_timer_provider.dart';

class CookingModeIngredientsList extends ConsumerStatefulWidget {
  final List<IngredientSection> ingredientSections;
  final VoidCallback onExpandToggle;
  final bool isExpanded;
  final String recipeId;
  final int stepNumber;
  final int currentPortions;

  const CookingModeIngredientsList({
    super.key,
    required this.ingredientSections,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.recipeId,
    required this.stepNumber,
    required this.currentPortions,
  });

  @override
  ConsumerState<CookingModeIngredientsList> createState() =>
      _CookingModeIngredientsListState();
}

class _CookingModeIngredientsListState
    extends ConsumerState<CookingModeIngredientsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final savedTimers = ref.watch(recipeTimersProvider(widget.recipeId));
    final hasTimer = savedTimers.value?[widget.stepNumber] != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle-Button
        Stack(
          children: [
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
                          style:
                              themeData.textTheme.bodyLargeEmphasis?.copyWith(
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
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: AppDimensions.animationDuration,
                child: hasTimer
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : IconButton(
                        key: const ValueKey('timer'),
                        onPressed: () => showCookingModeTimerPicker(
                          context,
                          recipeId: widget.recipeId,
                          stepIndex: widget.stepNumber,
                        ),
                        icon: const Icon(Icons.add_alarm, size: 22),
                        color: themeData.colorScheme.onPrimary,
                      ),
              ),
            ),
          ],
        ),

        // Expandierbarer Inhalt mit MaxHeight
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Visibility(
            visible: widget.isExpanded,
            child: ConstrainedBox(
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
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                        final hasMultipleSections =
                            widget.ingredientSections.length > 1;

                        if (section.isLinked) {
                          return _CookingModeLinkedSection(
                            section: section,
                            isLastSection: isLastSection,
                            currentPortions: widget.currentPortions,
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasMultipleSections &&
                                  section.title.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        section.title.toUpperCase(),
                                        style: themeData
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                          color: themeData
                                              .colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 1,
                                        width: 40,
                                        color: themeData.colorScheme.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
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
                                          text: "  \u2022  ",
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

class _CookingModeLinkedSection extends ConsumerWidget {
  final IngredientSection section;
  final bool isLastSection;
  final int currentPortions;

  const _CookingModeLinkedSection({
    required this.section,
    required this.isLastSection,
    required this.currentPortions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final asyncRecipe = ref.watch(linkedRecipeProvider(section.linkedRecipeId!));
    final displayName = asyncRecipe.asData?.value?.name ?? section.title;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => context.router.root
                  .push(ShowRecipeRoute(recipeId: section.linkedRecipeId!)),
              child: Row(
                children: [
                  Icon(Icons.link, size: 14, color: themeData.colorScheme.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      displayName.toUpperCase(),
                      style: themeData.textTheme.labelSmall?.copyWith(
                        color: themeData.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          asyncRecipe.when(
            data: (linkedRecipe) {
              if (linkedRecipe == null) {
                return Text(
                  'Rezept nicht verfügbar',
                  style: themeData.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                );
              }
              final scaleFactor = currentPortions / linkedRecipe.portions;
              final ingredients = linkedRecipe.ingredientSections
                  .expand((s) => s.ingredients)
                  .map((ing) => ing.scale(scaleFactor))
                  .toList();
              return Text.rich(
                TextSpan(
                  style: themeData.textTheme.bodyMedium,
                  children: ingredients
                      .asMap()
                      .entries
                      .expand<TextSpan>((entry) {
                    final index = entry.key;
                    final ing = entry.value;
                    return [
                      if (index != 0) TextSpan(text: "  \u2022  "),
                      ...ing.toInlineTextSpans(
                        nameStyle: themeData.textTheme.bodyMediumEmphasis,
                      ),
                    ];
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => Text(
              'Fehler beim Laden',
              style: themeData.textTheme.bodySmall?.copyWith(
                color: themeData.colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!isLastSection) const Divider(),
        ],
      ),
    );
  }
}
