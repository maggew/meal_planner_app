import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';

class CookingModeRecipeTabBar extends ConsumerWidget {
  final VoidCallback? onRemoveRecipe;
  final VoidCallback? onAddRecipe;

  const CookingModeRecipeTabBar({
    super.key,
    this.onRemoveRecipe,
    this.onAddRecipe,
  });

  static const double _dividerWidth = 1.0;
  static const double _addTabWidth = 46.0;
  static const double _scrollableTabWidth = 120.0;
  static const double _indicatorHeight = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = ref.watch(activeCookingSessionProvider);
    final timers = ref.watch(activeTimerProvider);
    final recipes = session.recipes;

    if (recipes.length < 2) return const SizedBox.shrink();

    final selectedIndex = recipes.indexWhere(
      (r) => r.recipeId == session.currentRecipeId,
    );
    final isScrollable = recipes.length > 4;

    final tabWidgets = recipes.map((entry) {
      final isSelected = entry.recipeId == session.currentRecipeId;
      final timerBadge = _getTimerBadge(entry.recipeId, timers);
      return _RecipeTab(
        entry: entry,
        isSelected: isSelected,
        timerBadge: timerBadge,
        onTap: () => ref
            .read(activeCookingSessionProvider.notifier)
            .setCurrentRecipe(entry.recipeId),
        onRemove: () => _confirmRemove(context, ref, entry),
      );
    }).toList();

    final divider = Container(
      width: _dividerWidth,
      color: colorScheme.onSurface.withValues(alpha: 0.15),
    );

    final addTab = GestureDetector(
      onTap: onAddRecipe,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _addTabWidth,
        child: Center(
          child: Icon(
            Icons.add,
            size: 22,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );

    return Container(
      color: colorScheme.surface,
      height: 72,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabCount = recipes.length;
          final double tabWidth;
          final double tabsAreaWidth;
          if (isScrollable) {
            tabWidth = _scrollableTabWidth;
            tabsAreaWidth =
                tabCount * tabWidth + (tabCount - 1) * _dividerWidth;
          } else {
            final available =
                constraints.maxWidth - _addTabWidth - tabCount * _dividerWidth;
            tabWidth = available / tabCount;
            tabsAreaWidth =
                tabCount * tabWidth + (tabCount - 1) * _dividerWidth;
          }

          final indicatorLeft =
              selectedIndex < 0 ? 0.0 : selectedIndex * (tabWidth + _dividerWidth);

          final tabsStack = SizedBox(
            width: tabsAreaWidth,
            height: 72,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < tabWidgets.length; i++) ...[
                      if (i > 0) divider,
                      SizedBox(width: tabWidth, child: tabWidgets[i]),
                    ],
                  ],
                ),
                AnimatedPositioned(
                  duration: AppDimensions.animationDuration,
                  curve: Curves.easeOut,
                  left: indicatorLeft,
                  bottom: 0,
                  width: tabWidth,
                  height: _indicatorHeight,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: isScrollable
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: tabsStack,
                      )
                    : tabsStack,
              ),
              divider,
              addTab,
            ],
          );
        },
      ),
    );
  }

  _TimerBadge? _getTimerBadge(
      String recipeId, Map<String, ActiveTimer> timers) {
    bool hasRunning = false;
    bool hasFinished = false;
    for (final timer in timers.values) {
      if (timer.recipeId != recipeId) continue;
      if (timer.status == TimerStatus.running ||
          timer.status == TimerStatus.paused) {
        hasRunning = true;
      }
      if (timer.status == TimerStatus.finished) {
        hasFinished = true;
      }
    }
    if (hasFinished) return _TimerBadge.finished;
    if (hasRunning) return _TimerBadge.running;
    return null;
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    CookingRecipeEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezept entfernen'),
        content:
            Text('"${entry.recipeName}" aus dem Kochmodus entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(activeCookingSessionProvider.notifier)
          .removeRecipe(entry.recipeId);
      onRemoveRecipe?.call();
    }
  }
}

enum _TimerBadge { running, finished }

class _RecipeTab extends StatelessWidget {
  final CookingRecipeEntry entry;
  final bool isSelected;
  final _TimerBadge? timerBadge;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecipeTab({
    required this.entry,
    required this.isSelected,
    required this.timerBadge,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timerBadge != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: timerBadge == _TimerBadge.finished
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(
                    entry.recipeName,
                    style: textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
