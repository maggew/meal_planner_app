import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_appbar_actions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_bottom_navigation_bar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_overview.dart';
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
      final recipe =
          await ref.read(recipeRepositoryProvider).getRecipeById(widget.recipeId!);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Image _buildImage(Recipe recipe) {
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty) return fallback;
    return Image.network(
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => context.router.pop(),
        ),
        title: _recipe!.name,
        actionsButtons: [
          ShowRecipeAppBarActions(recipe: _recipe!),
        ],
      ),
      scaffoldBottomNavigationBar:
          ShowRecipeBottomNavigationBar(tabController: _tabController),
      scaffoldBody: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ShowRecipeOverview(recipe: _recipe!, image: _image!),
          ShowRecipeCookingMode(
            recipe: _recipe!,
            initialStep: widget.initialStep,
          ),
        ],
      ),
    );
  }
}
