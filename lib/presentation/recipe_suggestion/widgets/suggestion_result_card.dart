import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class SuggestionResultCard extends ConsumerWidget {
  final RecipeSuggestion suggestion;
  final DateTime targetDate;
  final MealType targetMealType;
  final List<String> cookIds;

  const SuggestionResultCard({
    super.key,
    required this.suggestion,
    required this.targetDate,
    required this.targetMealType,
    this.cookIds = const [],
  });

  void _assignDirect(BuildContext context, WidgetRef ref) {
    ref.read(mealPlanActionsProvider).addEntry(
          date: targetDate,
          mealType: targetMealType,
          recipeId: suggestion.recipe.id,
          cookIds: cookIds,
        );
    context.router.maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion.recipe.name} eingeplant!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openRecipe(BuildContext context) {
    final recipe = suggestion.recipe;
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    final recipeImage = (recipe.imageUrl == null || recipe.imageUrl!.isEmpty)
        ? fallback
        : Image.network(
            recipe.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );
    context.router.root.push(ShowRecipeRoute(recipe: recipe, image: recipeImage));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final recipe = suggestion.recipe;
    final showCarbTags = ref.watch(
      sessionProvider.select((s) => s.group?.settings.showCarbTags ?? false),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        onTap: () => _openRecipe(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              if (recipe.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recipe.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(colorScheme),
                  ),
                )
              else
                _placeholder(colorScheme),
              const SizedBox(width: 12),
              // Name + tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showCarbTags && recipe.carbTags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: recipe.carbTags.map((tag) {
                          final carbTag = CarbTag.values
                              .where((t) => t.value == tag)
                              .firstOrNull;
                          return Chip(
                            label: Text(carbTag?.displayName ?? tag),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: colorScheme.onTertiaryContainer),
                            backgroundColor: colorScheme.tertiaryContainer
                                .withValues(alpha: 0.6),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (suggestion.totalInputIngredients > 0) ...[
                          Text(
                            '${suggestion.matchedIngredientCount}/${suggestion.totalInputIngredients} Zutaten',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(' · ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant)),
                        ],
                        Text(
                          '${(suggestion.totalScore * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Assign button
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Übernehmen',
                onPressed: () => _assignDirect(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: colorScheme.onSurfaceVariant),
    );
  }
}

