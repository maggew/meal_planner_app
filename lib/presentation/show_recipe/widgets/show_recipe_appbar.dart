import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class ShowRecipeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final Recipe recipe;
  const ShowRecipeAppbar({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
          ),
          onPressed: () {
            context.router.pop();
          }),
      centerTitle: true,
      title: FittedBox(
          child: Text(
        recipe.name,
        style: Theme.of(context).textTheme.displayMedium,
      )),
      actions: [
        IconButton(
          onPressed: () => _showEditDialog(context, ref),
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.black,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () => _showDeleteDialog(context, ref),
          icon: Icon(
            AppIcons.trash_bin,
            color: Colors.black,
            size: 20,
          ),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rezept bearbeiten'),
        content: Text('Möchtest du "${recipe.name}" bearbeiten?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Bearbeiten'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.router.push(AddEditRecipeRoute(existingRecipe: recipe));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rezept löschen'),
        content: Text('Möchtest du "${recipe.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteRecipe(context, ref);
    }
  }

  Future<void> _deleteRecipe(BuildContext context, WidgetRef ref) async {
    try {
      final recipeRepo = ref.read(recipeRepositoryProvider);
      await recipeRepo.deleteRecipe(recipe.id!);

      // Provider für alle Kategorien invalidieren
      for (final category in categoryNames) {
        ref.invalidate(recipesPaginationProvider(category.toLowerCase()));
      }

      if (context.mounted) {
        context.router.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
