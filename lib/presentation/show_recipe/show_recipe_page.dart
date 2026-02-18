import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_appbar.dart';
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
    return (recipe.imageUrl == null || recipe.imageUrl!.isEmpty)
        ? Image.asset('assets/images/caticorn.png', fit: BoxFit.cover)
        : Image.network(recipe.imageUrl!, fit: BoxFit.cover);
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
        scaffoldAppBar: ShowRecipeAppbar(recipe: _recipe!),
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
}
