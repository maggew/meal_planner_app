import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe_suggestion.dart';
import 'package:meal_planner/domain/entities/suggestion_usage.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/presentation/recipe_suggestion/widgets/ingredient_input_widget.dart';
import 'package:meal_planner/presentation/recipe_suggestion/widgets/suggestion_result_card.dart';
import 'package:meal_planner/presentation/subscription/widgets/paywall_sheet.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';
import 'package:meal_planner/services/providers/subscription/suggestion_usage_provider.dart';
import 'package:meal_planner/services/providers/suggestion/recipe_suggestion_provider.dart';

class RecipeSuggestionBody extends ConsumerStatefulWidget {
  final DateTime referenceDate;
  final MealType mealType;
  final List<String> cookIds;

  const RecipeSuggestionBody({
    super.key,
    required this.referenceDate,
    required this.mealType,
    this.cookIds = const [],
  });

  @override
  ConsumerState<RecipeSuggestionBody> createState() =>
      _RecipeSuggestionBodyState();
}

class _RecipeSuggestionBodyState extends ConsumerState<RecipeSuggestionBody> {
  List<String> _ingredients = [];

  @override
  Widget build(BuildContext context) {
    final suggestionState = ref.watch(recipeSuggestionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isPremium = ref.watch(isPremiumProvider);
    final usageAsync = ref.watch(suggestionUsageProvider);

    final perfect = suggestionState.suggestions
        .where((s) => s.matchQuality == MatchQuality.perfect)
        .toList();
    final partial = suggestionState.suggestions
        .where((s) => s.matchQuality == MatchQuality.partial)
        .toList();
    final other = suggestionState.suggestions
        .where((s) => s.matchQuality == MatchQuality.other)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenMargin,
        20,
        AppDimensions.screenMargin,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vorhandene Zutaten',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                IngredientInputWidget(
                  ingredients: _ingredients,
                  onChanged: (updated) =>
                      setState(() => _ingredients = updated),
                ),
                const SizedBox(height: 16),
                if (!isPremium)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: usageAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (usage) => Text(
                        '${usage.usageCount} von ${SuggestionUsage.freeWeeklyLimit} Vorschläge diese Woche',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: suggestionState.isLoading
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            ref
                                .read(recipeSuggestionProvider.notifier)
                                .suggest(_ingredients, referenceDate: widget.referenceDate);
                          },
                    icon: suggestionState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Vorschlagen'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (suggestionState.error == 'limit_reached') ...[
            const SizedBox(height: 16),
            GlassCard(
              borderColor: colorScheme.primary.withValues(alpha: 0.3),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wöchentliches Limit erreicht',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mit Premium erhältst du unbegrenzte Vorschläge und alle Rezepte.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => showPaywallSheet(context),
                      child: const Text('Premium holen'),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (suggestionState.error != null) ...[
            const SizedBox(height: 16),
            Text(
              'Fehler: ${suggestionState.error}',
              style: TextStyle(color: colorScheme.error),
            ),
          ],
          if (suggestionState.suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            if (perfect.isNotEmpty) ...[
              _SectionHeader(title: 'Beste Treffer'),
              ...perfect
                  .map((s) => SuggestionResultCard(
                    suggestion: s,
                    targetDate: widget.referenceDate,
                    targetMealType: widget.mealType,
                    cookIds: widget.cookIds,
                  )),
            ],
            if (partial.isNotEmpty) ...[
              if (perfect.isNotEmpty) const SizedBox(height: 8),
              _SectionHeader(title: 'Teilweise passend'),
              ...partial
                  .map((s) => SuggestionResultCard(
                    suggestion: s,
                    targetDate: widget.referenceDate,
                    targetMealType: widget.mealType,
                    cookIds: widget.cookIds,
                  )),
            ],
            if (other.isNotEmpty) ...[
              if (perfect.isNotEmpty || partial.isNotEmpty)
                const SizedBox(height: 8),
              _SectionHeader(title: 'Weitere Vorschläge'),
              ...other
                  .map((s) => SuggestionResultCard(
                    suggestion: s,
                    targetDate: widget.referenceDate,
                    targetMealType: widget.mealType,
                    cookIds: widget.cookIds,
                  )),
            ],
          ] else if (!suggestionState.isLoading &&
              suggestionState.error == null) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Zutaten eingeben und\nVorschläge generieren',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
