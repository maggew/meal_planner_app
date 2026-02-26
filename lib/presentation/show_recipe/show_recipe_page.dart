import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/categories.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_bottom_navigation_bar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_overview.dart';
import 'package:meal_planner/presentation/common/plan_recipe_sheet.dart';
import 'package:meal_planner/services/providers/recipe/recipe_pagination_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

@RoutePage()
class ShowRecipePage extends ConsumerStatefulWidget {
  final Recipe? recipe;
  final Image? image;
  final String? recipeId;
  final int? initialStep;
  const ShowRecipePage({
    super.key,
    this.recipe,
    this.image,
    this.recipeId,
    this.initialStep,
  }) : assert(
          recipe != null || recipeId != null,
          'Entweder recipe oder recipeId muss übergeben werden',
        );

  @override
  ConsumerState<ShowRecipePage> createState() => _ShowRecipePageState();
}

class _ShowRecipePageState extends ConsumerState<ShowRecipePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Recipe? _recipe;
  Image? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.recipe != null) {
      _recipe = widget.recipe;
      _image = widget.image ?? _buildImage(widget.recipe!);
      _isLoading = false;
    } else if (widget.recipeId != null) {
      _loadRecipe();
    }
  }

  Future<void> _loadRecipe() async {
    try {
      final recipeRepo = ref.read(recipeRepositoryProvider);
      final recipe = await recipeRepo.getRecipeById(widget.recipeId!);
      if (recipe != null && mounted) {
        setState(() {
          _recipe = recipe;
          _image = _buildImage(recipe);
          _isLoading = false;
        });

        if (widget.initialStep != null) {
          _tabController.animateTo(1);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Image _buildImage(Recipe recipe) {
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    return (recipe.imageUrl == null || recipe.imageUrl!.isEmpty)
        ? fallback
        : Image.network(
            recipe.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            },
            errorBuilder: (_, __, ___) => fallback,
          );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rezept nicht gefunden'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.router.maybePop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      );
    }
    return AppBackground(
        scaffoldAppBar: CommonAppbar(
          leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                context.router.pop();
              }),
          title: _recipe!.name,
          actionsButtons: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: 'Zum Wochenplan',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => PlanRecipeSheet(
                  recipeId: _recipe!.id!,
                  recipeName: _recipe!.name,
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
                PopupMenuItem(
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
                    title: Text('Löschen'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        scaffoldBottomNavigationBar: ShowRecipeBottomNavigationBar(
          tabController: _tabController,
        ),
        scaffoldBody: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ShowRecipeOverview(
              recipe: _recipe!,
              image: _image!,
            ),
            ShowRecipeCookingMode(
              recipe: _recipe!,
              initialStep: widget.initialStep,
            ),
          ],
        ));
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rezept bearbeiten'),
        content: Text('Möchtest du "${_recipe!.name}" bearbeiten?'),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(false),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => context.router.maybePop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Bearbeiten'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.router.root.push(AddEditRecipeRoute(existingRecipe: _recipe));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rezept löschen'),
        content: Text('Möchtest du "${_recipe!.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => context.router.maybePop(false),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => context.router.maybePop(true),
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
      await recipeRepo.deleteRecipe(_recipe!.id!);

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
}
