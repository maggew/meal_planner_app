import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/plan_recipe_sheet.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class ShowRecipeAppBarActions extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback? onAddRecipe;

  const ShowRecipeAppBarActions({
    super.key,
    required this.recipe,
    this.onAddRecipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'add':
            onAddRecipe?.call();
          case 'plan':
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => PlanRecipeSheet(
                recipeId: recipe.id!,
                recipeName: recipe.name,
              ),
            );
          case 'edit':
            _showEditDialog(context);
          case 'delete':
            _showDeleteDialog(context, ref);
        }
      },
      itemBuilder: (context) => [
        if (onAddRecipe != null)
          const PopupMenuItem(
            value: 'add',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Rezept hinzufügen'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuItem(
          value: 'plan',
          child: ListTile(
            leading: Icon(Icons.calendar_month_outlined),
            title: Text('Zum Wochenplan'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Bearbeiten'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(AppIcons.trash_bin),
            title: const Text('Löschen'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezept bearbeiten'),
        content: Text('Möchtest du "${recipe.name}" bearbeiten?'),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => context.router.maybePop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Bearbeiten'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.router.root.push(AddEditRecipeRoute(existingRecipe: recipe));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezept löschen'),
        content: Text('Möchtest du "${recipe.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => context.router.maybePop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
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
      await ref.read(recipeDeletionServiceProvider).deleteRecipe(recipe.id!);

      final allCategories = await ref.read(groupCategoriesProvider.future);
      for (final category in allCategories) {
        ref.invalidate(categoryRecipesProvider(category.id));
      }

      if (context.mounted) context.router.pop();
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
}
