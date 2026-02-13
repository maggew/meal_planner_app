import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class CookbookSortingButton extends ConsumerWidget {
  const CookbookSortingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<RecipeSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sortierung',
      onSelected: (option) {
        final settings =
            ref.read(sessionProvider).settings ?? UserSettings.defaultSettings;
        ref.read(sessionProvider.notifier).changeSettings(
              settings.copyWith(recipeSortOption: option),
            );
      },
      itemBuilder: (context) {
        final current = ref.read(sessionProvider).settings?.recipeSortOption ??
            RecipeSortOption.alphabetical;

        return [
          PopupMenuItem(
            value: RecipeSortOption.alphabetical,
            child: ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('A-Z'),
              trailing: current == RecipeSortOption.alphabetical
                  ? const Icon(Icons.check, size: 18)
                  : null,
              dense: true,
            ),
          ),
          PopupMenuItem(
            value: RecipeSortOption.newest,
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Neueste'),
              trailing: current == RecipeSortOption.newest
                  ? const Icon(Icons.check, size: 18)
                  : null,
              dense: true,
            ),
          ),
          PopupMenuItem(
            value: RecipeSortOption.oldest,
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Älteste'),
              trailing: current == RecipeSortOption.oldest
                  ? const Icon(Icons.check, size: 18)
                  : null,
              dense: true,
            ),
          ),
          PopupMenuItem(
            value: RecipeSortOption.mostCooked,
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Beliebt'),
              trailing: current == RecipeSortOption.mostCooked
                  ? const Icon(Icons.check, size: 18)
                  : null,
              dense: true,
            ),
          ),
        ];
      },
    );
  }
}
