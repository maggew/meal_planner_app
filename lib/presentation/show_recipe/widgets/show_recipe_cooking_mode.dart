import 'package:flutter/material.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_page_buttons.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_step_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ShowRecipeCookingMode extends StatefulWidget {
  final Recipe recipe;
  const ShowRecipeCookingMode({super.key, required this.recipe});

  @override
  State<ShowRecipeCookingMode> createState() => _ShowRecipeCookingModeState();
}

class _ShowRecipeCookingModeState extends State<ShowRecipeCookingMode>
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
    _tabController = TabController(length: instructions.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
                instructions.length,
                (index) => CookingModeStepWidget(
                      instructionStep: instructions[index],
                      stepNumber: index + 1,
                      ingredientSections: widget.recipe.ingredientSections,
                      isExpanded: isIngredientsExpanded,
                      onExpandToggle: () => setState(() {
                        isIngredientsExpanded = !isIngredientsExpanded;
                      }),
                    )).toList()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: CookingModePageButtons(tabController: _tabController),
        ),
      ],
    );
  }

  List<String> _parseInstructions() {
    // Findest alle Zeilen, die mit "1. ", "2. " etc. beginnen
    final regex = RegExp(r'^\d+\.\s+(.+)$', multiLine: true);
    final matches = regex.allMatches(widget.recipe.instructions);

    return matches.map((m) => m.group(1)!).toList();
  }
}
