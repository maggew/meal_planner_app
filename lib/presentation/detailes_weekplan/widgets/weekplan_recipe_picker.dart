import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class WeekplanRecipePicker extends ConsumerStatefulWidget {
  final void Function(String recipeId) onSelected;

  const WeekplanRecipePicker({super.key, required this.onSelected});

  @override
  ConsumerState<WeekplanRecipePicker> createState() =>
      _WeekplanRecipePickerState();
}

class _WeekplanRecipePickerState extends ConsumerState<WeekplanRecipePicker> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final dao = ref.watch(recipeCacheDaoProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadius),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text('Rezept auswählen', style: textTheme.titleSmall),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Rezept suchen …',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                ),
              ),
              const SizedBox(height: 8),

              // Recipe list
              Expanded(
                child: StreamBuilder<List<LocalRecipe>>(
                  stream: dao.watchRecipesByGroup(groupId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final recipes = snapshot.data!
                        .where((r) =>
                            _searchQuery.isEmpty ||
                            r.name.toLowerCase().contains(_searchQuery))
                        .toList();

                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          'Keine Rezepte gefunden',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          title: Text(recipe.name, style: textTheme.bodyMedium),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelected(recipe.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
