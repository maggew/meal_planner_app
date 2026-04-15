import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_switch_step_page_button.dart';

class CookingModePageButtons extends StatefulWidget {
  final TabController tabController;
  final VoidCallback? onFinished;
  const CookingModePageButtons({
    super.key,
    required this.tabController,
    this.onFinished,
  });

  @override
  State<CookingModePageButtons> createState() => _CookingModePageButtonsState();
}

class _CookingModePageButtonsState extends State<CookingModePageButtons> {
  @override
  Widget build(BuildContext context) {
    bool isFirstPage = widget.tabController.index == 0;
    bool isLastPage =
        widget.tabController.index == widget.tabController.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: isFirstPage
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : CookingModeSwitchStepPageButton(
                    key: const ValueKey('back'),
                    label: "Zurück",
                    icon: Icons.arrow_back_outlined,
                    onPressed: () {
                      if (widget.tabController.index > 0) {
                        setState(() => widget.tabController.index--);
                      }
                    },
                  ),
          ),
          CookingModeSwitchStepPageButton(
            key: ValueKey("Weiter"),
            label: isLastPage ? "Fertig" : "Weiter",
            icon: isLastPage ? Icons.check : Icons.arrow_forward_outlined,
            onPressed: () {
              if (isLastPage) {
                widget.onFinished?.call();
              } else if (widget.tabController.index <
                  widget.tabController.length - 1) {
                setState(() => widget.tabController.index++);
              }
            },
            iconAfter: true,
          ),
        ],
      ),
    );
  }
}
