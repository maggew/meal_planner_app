import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/plan_recipe_sheet.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class ShowRecipeAppBarActions extends ConsumerWidget {
  final Recipe recipe;

  const ShowRecipeAppBarActions({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          tooltip: 'Zum Wochenplan',
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => PlanRecipeSheet(
              recipeId: recipe.id!,
              recipeName: recipe.name,
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(context);
              case 'delete':
                _showDeleteDialog(context, ref);
            }
          },
          itemBuilder: (context) => [
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
      await ref.read(recipeRepositoryProvider).deleteRecipe(recipe.id!);

      final allCategories =
          ref.read(groupCategoriesProvider).asData?.value ?? [];
      final recipeCategories = recipe.categories.toSet();
      for (final category in allCategories) {
        if (recipeCategories.contains(category.name)) {
          ref.invalidate(recipesPaginationProvider(category.id));
        }
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
