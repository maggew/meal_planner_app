import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_switch_step_page_button.dart';

class CookingModePageButtons extends StatelessWidget {
  final TabController tabController;
  const CookingModePageButtons({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          CookingModeSwitchStepPageButton(
            label: "Links",
            icon: Icons.arrow_back_outlined,
            onPressed: () {
              (tabController.index > 0)
                  ? tabController.index--
                  : print("first page!");
            },
          ),
          CookingModeSwitchStepPageButton(
            label: "Rechts",
            isPrimary: true,
            icon: Icons.arrow_forward_outlined,
            onPressed: () {
              (tabController.index < tabController.length - 1)
                  ? tabController.index++
                  : print("last page!");
            },
            iconAfter: true,
          ),
        ],
      ),
    );
  }
}
