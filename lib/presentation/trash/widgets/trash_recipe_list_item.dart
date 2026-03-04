import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/recipe/trash_provider.dart';

class TrashRecipeListItem extends ConsumerWidget {
  final Recipe recipe;
  const TrashRecipeListItem({required this.recipe, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    final recipeImage = (recipe.imageUrl == null ||
            recipe.imageUrl!.isEmpty ||
            recipe.imageUrl == 'assets/images/default_pic_2.jpg')
        ? fallback
        : Image.network(
            recipe.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2));
            },
            errorBuilder: (_, __, ___) => fallback,
          );

    return GestureDetector(
      onTap: () => context.router.root
          .push(ShowRecipeRoute(recipe: recipe, image: recipeImage)),
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(top: 10),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: recipeImage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recipe.name,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Wiederherstellen',
                    icon: const Icon(Icons.restore_rounded),
                    onPressed: () => _confirmRestore(context, ref),
                  ),
                  IconButton(
                    tooltip: 'Endgültig löschen',
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _confirmHardDelete(context, ref),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wiederherstellen?'),
        content: Text('"${recipe.name}" ins Kochbuch zurückbringen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(trashProvider.notifier).restoreRecipe(recipe.id!);
            },
            child: const Text('Wiederherstellen'),
          ),
        ],
      ),
    );
  }

  void _confirmHardDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endgültig löschen?'),
        content: Text(
            '"${recipe.name}" wird unwiderruflich gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(trashProvider.notifier).hardDeleteRecipe(recipe.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
