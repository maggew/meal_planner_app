import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/cooking_recipe_entry.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/common/adaptive_appbar_title.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode_recipe_tab_bar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_recipe_picker_sheet.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_appbar_actions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_bottom_navigation_bar.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_cooking_mode.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/show_recipe_overview.dart';
import 'package:meal_planner/services/providers/cooking/active_cooking_session_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

@RoutePage()
class ShowRecipePage extends ConsumerStatefulWidget {
  final Recipe? recipe;
  final Widget? image;
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
  late TabController _singleModeTabController;
  Recipe? _recipe;
  Widget? _image;
  bool _isLoading = true;
  int _currentPortions = 1;

  /// Loaded recipes for multi-mode (recipeId → Recipe)
  final Map<String, Recipe> _loadedRecipes = {};
  final Map<String, int> _multiPortions = {};

  List<IngredientSection> _scaledSections(Recipe recipe, int portions) {
    final factor = recipe.portions > 0 ? portions / recipe.portions : 1.0;
    if (factor == 1.0) return recipe.ingredientSections;
    return recipe.ingredientSections
        .map(
          (section) => IngredientSection(
            title: section.title,
            ingredients:
                section.ingredients.map((i) => i.scale(factor)).toList(),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _singleModeTabController = TabController(length: 2, vsync: this);
    _singleModeTabController.addListener(_onSingleModeTabChanged);

    if (widget.recipe != null) {
      _recipe = widget.recipe;
      _currentPortions = widget.recipe!.portions;
      _image = widget.image ?? _buildImage(widget.recipe!);
      _isLoading = false;
      if (widget.recipe!.id != null) {
        _loadedRecipes[widget.recipe!.id!] = widget.recipe!;
        _multiPortions[widget.recipe!.id!] = widget.recipe!.portions;
      }
      _restoreTabFromSession();
      _loadSessionRecipes();
    } else if (widget.recipeId != null) {
      _loadRecipe();
    }
  }

  void _onSingleModeTabChanged() {
    if (_singleModeTabController.indexIsChanging) return;
    final session = ref.read(activeCookingSessionProvider);
    final notifier = ref.read(activeCookingSessionProvider.notifier);

    if (_singleModeTabController.index == 1) {
      if (_recipe?.id != null) {
        final wasActive = session.isActive;
        notifier.addRecipe(CookingRecipeEntry(
          recipeId: _recipe!.id!,
          recipeName: _recipe!.name,
          imageUrl: _recipe!.imageUrl,
        ));
        if (wasActive) {
          notifier.setCurrentRecipe(_recipe!.id!);
          notifier.setWasInCookingMode(true);
        }
      }
    } else {
      if (session.isActive && session.recipes.length == 1) {
        final timers = ref.read(activeTimerProvider);
        final recipeIds = session.recipes.map((e) => e.recipeId).toSet();
        final hasActiveTimers = timers.values.any(
          (t) =>
              recipeIds.contains(t.recipeId) &&
              (t.status == TimerStatus.running ||
                  t.status == TimerStatus.paused),
        );
        if (!hasActiveTimers) notifier.clearSession();
      }
    }
  }

  void _restoreTabFromSession() {
    final session = ref.read(activeCookingSessionProvider);
    final currentId = _recipe?.id;
    if (!session.isActive || currentId == null) return;
    if (!session.isRecipeActive(currentId)) return;
    if (session.wasInCookingMode && _singleModeTabController.index != 1) {
      _singleModeTabController.index = 1;
    }
  }

  Future<void> _loadRecipe() async {
    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .getRecipeById(widget.recipeId!);
      if (recipe != null && mounted) {
        _loadedRecipes[recipe.id!] = recipe;
        _multiPortions[recipe.id!] = recipe.portions;
        setState(() {
          _recipe = recipe;
          _currentPortions = recipe.portions;
          _image = _buildImage(recipe);
          _isLoading = false;
        });
        if (widget.initialStep != null) {
          _singleModeTabController.animateTo(1);
        } else {
          _restoreTabFromSession();
        }
        _loadSessionRecipes();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadSessionRecipes() {
    final session = ref.read(activeCookingSessionProvider);
    if (!session.isActive) return;
    for (final entry in session.recipes) {
      if (!_loadedRecipes.containsKey(entry.recipeId)) {
        _loadRecipeForMulti(entry.recipeId);
      }
    }
  }

  Widget _buildImage(Recipe recipe) {
    final fallback = Image.asset('assets/images/Rosi.png', fit: BoxFit.cover);
    if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: recipe.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) => fallback,
    );
  }

  Future<void> _onAddRecipe() async {
    final picked = await showCookingRecipePicker(context);
    if (picked == null || !mounted) return;

    final session = ref.read(activeCookingSessionProvider.notifier);

    // Add current recipe to session if not already there
    if (_recipe != null &&
        !ref
            .read(activeCookingSessionProvider)
            .isRecipeActive(_recipe!.id!)) {
      session.addRecipe(CookingRecipeEntry(
        recipeId: _recipe!.id!,
        recipeName: _recipe!.name,
        imageUrl: _recipe!.imageUrl,
      ));
      _loadedRecipes[_recipe!.id!] = _recipe!;
      _multiPortions[_recipe!.id!] = _currentPortions;
    }

    // Add picked recipe
    session.addRecipe(CookingRecipeEntry(
      recipeId: picked.id,
      recipeName: picked.name,
      imageUrl: picked.imageUrl,
    ));

    // Load picked recipe if not already loaded
    if (!_loadedRecipes.containsKey(picked.id)) {
      _loadRecipeForMulti(picked.id);
    }
  }

  Future<void> _loadRecipeForMulti(String recipeId) async {
    try {
      final recipe =
          await ref.read(recipeRepositoryProvider).getRecipeById(recipeId);
      if (recipe != null && mounted) {
        setState(() {
          _loadedRecipes[recipeId] = recipe;
          _multiPortions[recipeId] = recipe.portions;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _singleModeTabController.removeListener(_onSingleModeTabChanged);
    _singleModeTabController.dispose();
    _cleanupSessionIfNoTimers(_cachedSession, _cachedTimers, _cachedNotifier);
    super.dispose();
  }

  // Cached in build() so dispose() can use them safely without ref
  ActiveCookingSessionState? _cachedSession;
  Map<String, ActiveTimer>? _cachedTimers;
  ActiveCookingSession? _cachedNotifier;

  void _cleanupSessionIfNoTimers(
    ActiveCookingSessionState? session,
    Map<String, ActiveTimer>? timers,
    ActiveCookingSession? notifier,
  ) {
    if (session == null || !session.isActive) return;
    if (timers == null || notifier == null) return;
    if (session.recipes.length > 1) return;

    // User left from cooking tab → keep session so mini-bar stays visible.
    if (session.wasInCookingMode) return;

    final sessionRecipeIds = session.recipes.map((e) => e.recipeId).toSet();
    final hasActiveTimers = timers.values.any((t) =>
        sessionRecipeIds.contains(t.recipeId) &&
        (t.status == TimerStatus.running || t.status == TimerStatus.paused));

    if (!hasActiveTimers) notifier.clearSession();
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

    final session = ref.watch(activeCookingSessionProvider);
    final isMultiMode = session.recipes.length >= 2 &&
        _recipe?.id != null &&
        session.isRecipeActive(_recipe!.id!);

    // Cache for safe access in dispose()
    _cachedSession = session;
    _cachedTimers = ref.watch(activeTimerProvider);
    _cachedNotifier = ref.read(activeCookingSessionProvider.notifier);

    // Multi-mode: auto-navigate to recipe tab on timer expiry
    ref.listen(activeTimerProvider, (prev, next) {
      if (!mounted || !isMultiMode) return;
      final autoNav =
          ref.read(userSettingsProvider).autoNavigateOnTimerExpiry;
      if (!autoNav) return;

      final currentSession = ref.read(activeCookingSessionProvider);
      for (final entry in next.entries) {
        final timer = entry.value;
        if (timer.status != TimerStatus.finished) continue;
        final prevTimer = prev?[entry.key];
        if (prevTimer?.status == TimerStatus.finished) continue;

        if (timer.recipeId != currentSession.currentRecipeId &&
            currentSession.isRecipeActive(timer.recipeId)) {
          ref
              .read(activeCookingSessionProvider.notifier)
              .setCurrentRecipe(timer.recipeId);
        }
      }
    });

    return AppBackground(
      applyScreenPadding: true,
      scaffoldAppBar: CommonAppbar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => context.router.pop(),
        ),
        title: _recipe!.name,
        titleWidget: isMultiMode
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: AdaptiveAppBarTitle(
                  key: ValueKey(session.currentRecipeId),
                  text: session.recipes
                          .where(
                              (e) => e.recipeId == session.currentRecipeId)
                          .firstOrNull
                          ?.recipeName ??
                      _recipe!.name,
                ),
              )
            : AdaptiveAppBarTitle(text: _recipe!.name),
        actionsButtons: [
          if (!isMultiMode)
            ShowRecipeAppBarActions(
              recipe: _recipe!,
              onAddRecipe: _onAddRecipe,
            ),
        ],
      ),
      scaffoldBottomNavigationBar: isMultiMode
          ? CookingModeRecipeTabBar(
              onAddRecipe: _onAddRecipe,
              onRemoveRecipe: () {
              final updated = ref.read(activeCookingSessionProvider);
              final newCurrentId = updated.currentRecipeId;
              if (updated.recipes.isNotEmpty &&
                  newCurrentId != null &&
                  _loadedRecipes.containsKey(newCurrentId)) {
                setState(() {
                  _recipe = _loadedRecipes[newCurrentId];
                  _currentPortions =
                      _multiPortions[newCurrentId] ?? _recipe!.portions;
                  _image = _buildImage(_recipe!);
                });
                if (updated.recipes.length == 1) {
                  _singleModeTabController.animateTo(1);
                }
              }
            })
          : ShowRecipeBottomNavigationBar(
              tabController: _singleModeTabController),
      scaffoldBody: isMultiMode
          ? _buildMultiModeBody(session)
          : _buildSingleModeBody(),
    );
  }

  int? _getSessionStep(String? recipeId) {
    if (recipeId == null) return null;
    final session = ref.read(activeCookingSessionProvider);
    final entry =
        session.recipes.where((e) => e.recipeId == recipeId).firstOrNull;
    return entry != null && entry.currentStep > 0 ? entry.currentStep : null;
  }

  Widget _buildSingleModeBody() {
    return TabBarView(
      controller: _singleModeTabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ShowRecipeOverview(
          recipe: _recipe!,
          image: _image!,
          scaledSections: _scaledSections(_recipe!, _currentPortions),
          currentPortions: _currentPortions,
          onPortionsChanged: (p) => setState(() => _currentPortions = p),
        ),
        ShowRecipeCookingMode(
          recipe: _recipe!,
          initialStep: widget.initialStep ?? _getSessionStep(_recipe!.id),
          scaledSections: _scaledSections(_recipe!, _currentPortions),
          currentPortions: _currentPortions,
        ),
      ],
    );
  }

  Widget _buildMultiModeBody(ActiveCookingSessionState session) {
    final currentId = session.currentRecipeId;

    return Stack(
      children: session.recipes.map((entry) {
        final isCurrent = entry.recipeId == currentId;
        final recipe = _loadedRecipes[entry.recipeId];
        if (recipe == null) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCurrent ? 1.0 : 0.0,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final portions =
            _multiPortions[entry.recipeId] ?? recipe.portions;
        return IgnorePointer(
          ignoring: !isCurrent,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCurrent ? 1.0 : 0.0,
            child: ShowRecipeCookingMode(
              key: ValueKey(entry.recipeId),
              recipe: recipe,
              initialStep: entry.currentStep > 0 ? entry.currentStep : null,
              scaledSections: _scaledSections(recipe, portions),
              currentPortions: portions,
            ),
          ),
        );
      }).toList(),
    );
  }
}
