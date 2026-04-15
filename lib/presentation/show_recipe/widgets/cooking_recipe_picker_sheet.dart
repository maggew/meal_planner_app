import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/recipe_cache_dao.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

/// Opens a modal bottom sheet to pick a recipe for multi-cooking mode.
///
/// Returns the selected [LocalRecipe], or null if dismissed.
Future<LocalRecipe?> showCookingRecipePicker(BuildContext context) {
  return showModalBottomSheet<LocalRecipe>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CookingRecipePickerSheet(),
  );
}

class _CookingRecipePickerSheet extends ConsumerStatefulWidget {
  const _CookingRecipePickerSheet();

  @override
  ConsumerState<_CookingRecipePickerSheet> createState() =>
      _CookingRecipePickerSheetState();
}

class _CookingRecipePickerSheetState
    extends ConsumerState<_CookingRecipePickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final dao = ref.watch(recipeCacheDaoProvider);
    final sessionState = ref.watch(activeCookingSessionProvider);
    final todayEntries = ref.watch(mealPlanStreamProvider(DateTime.now()));

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadius),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child:
                    Text('Rezept hinzufügen', style: textTheme.titleSmall),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Rezept suchen …',
                    prefixIcon: const Icon(Icons.search),
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  onChanged: (v) => setState(() {
                    _searchQuery = v.toLowerCase();
                  }),
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _buildContent(
                  context,
                  scrollController: scrollController,
                  dao: dao,
                  groupId: groupId,
                  sessionState: sessionState,
                  todayEntries: todayEntries,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required ScrollController scrollController,
    required RecipeCacheDao dao,
    required String groupId,
    required ActiveCookingSessionState sessionState,
    required AsyncValue<List<MealPlanEntry>> todayEntries,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return StreamBuilder<List<LocalRecipe>>(
      stream: dao.watchRecipesByGroup(groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRecipes = snapshot.data!;

        // Build today's recipe IDs from meal plan
        final todayRecipeIds = <String>{};
        if (todayEntries.hasValue) {
          for (final entry in todayEntries.value!) {
            if (entry.recipeId != null && entry.recipeId!.isNotEmpty) {
              todayRecipeIds.add(entry.recipeId!);
            }
          }
        }

        // Split into today's recipes and the rest
        final todayRecipes = allRecipes
            .where((r) => todayRecipeIds.contains(r.id))
            .toList();

        final filteredRecipes = allRecipes
            .where((r) =>
                _searchQuery.isEmpty ||
                r.name.toLowerCase().contains(_searchQuery))
            .toList();

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          children: [
            // "Heute auf dem Plan" section
            if (todayRecipes.isNotEmpty && _searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Text(
                  'Heute auf dem Plan',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              ...todayRecipes.map((recipe) => _RecipeTile(
                    recipe: recipe,
                    isActive: sessionState.isRecipeActive(recipe.id),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => Navigator.of(context).pop(recipe),
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Divider(
                    color: colorScheme.onSurface.withValues(alpha: 0.15)),
              ),
            ],

            // "Alle Rezepte" section
            if (filteredRecipes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Text(
                  _searchQuery.isEmpty ? 'Alle Rezepte' : 'Suchergebnisse',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),

            if (filteredRecipes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Keine Rezepte gefunden',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              ...filteredRecipes.map((recipe) => _RecipeTile(
                    recipe: recipe,
                    isActive: sessionState.isRecipeActive(recipe.id),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => Navigator.of(context).pop(recipe),
                  )),
          ],
        );
      },
    );
  }
}

class _RecipeTile extends StatelessWidget {
  final LocalRecipe recipe;
  final bool isActive;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _RecipeTile({
    required this.recipe,
    required this.isActive,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        recipe.name,
        style: textTheme.bodyMedium?.copyWith(
          color: isActive
              ? colorScheme.onSurface.withValues(alpha: 0.35)
              : null,
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle,
              color: colorScheme.primary.withValues(alpha: 0.5), size: 20)
          : const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: isActive ? null : onTap,
    );
  }
}
