import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_ingredients_list.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_page_buttons.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_indicator.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_widget.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ShowRecipeCookingMode extends ConsumerStatefulWidget {
  final Recipe recipe;
  final int? initialStep;
  final List<IngredientSection> scaledSections;

  const ShowRecipeCookingMode({
    super.key,
    required this.recipe,
    required this.scaledSections,
    this.initialStep,
  });

  @override
  ConsumerState<ShowRecipeCookingMode> createState() =>
      _ShowRecipeCookingModeState();
}

class _ShowRecipeCookingModeState extends ConsumerState<ShowRecipeCookingMode>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late List<String> instructions;
  late TabController _tabController;
  bool isIngredientsExpanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    WakelockPlus.disable();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    instructions = _parseInstructions();
    _tabController = TabController(
      length: instructions.length,
      vsync: this,
      initialIndex: widget.initialStep?.clamp(0, instructions.length - 1) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(activeTimerProvider, (prev, next) {
      final recipeId = widget.recipe.id;
      if (recipeId == null) return;

      for (final entry in next.entries) {
        final timer = entry.value;
        if (timer.recipeId != recipeId) continue;
        if (timer.status != TimerStatus.finished) continue;

        final prevTimer = prev?[entry.key];
        if (prevTimer?.status == TimerStatus.finished) continue;

        if (timer.stepIndex < instructions.length) {
          _tabController.animateTo(timer.stepIndex);
        }
      }
    });

    return Padding(
      padding: AppDimensions.screenPadding,
      child: Stack(
        children: [
          Column(
            children: [
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) => Column(
                  children: [
                    CookingModeStepIndicator(
                      totalSteps: instructions.length,
                      currentStep: _tabController.index,
                      onStepTapped: (index) => _tabController.animateTo(index),
                    ),
                    CookingModeIngredientsList(
                      isExpanded: isIngredientsExpanded,
                      onExpandToggle: () => setState(() {
                        isIngredientsExpanded = !isIngredientsExpanded;
                      }),
                      ingredientSections: widget.scaledSections,
                      recipeId: widget.recipe.id!,
                      stepNumber: _tabController.index,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                        instructions.length,
                        (index) => CookingModeStepWidget(
                              recipeId: widget.recipe.id!,
                              instructionStep: instructions[index],
                              stepNumber: index,
                              totalSteps: _tabController.length,
                            )).toList()),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) =>
                  CookingModePageButtons(tabController: _tabController),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseInstructions() {
    // Findest alle Zeilen, die mit "1. ", "2. " etc. beginnen
    final regex = RegExp(r'^\d+\.\s+(.+)$', multiLine: true);
    final matches = regex.allMatches(widget.recipe.instructions);
    final steps = matches.map((m) => m.group(1)!).toList();

    // Fallback: kein nummeriertes Format → ganzen Text als einen Schritt zeigen
    if (steps.isEmpty) {
      final raw = widget.recipe.instructions.trim();
      return [if (raw.isNotEmpty) raw else ''];
    }
    return steps;
  }
}
