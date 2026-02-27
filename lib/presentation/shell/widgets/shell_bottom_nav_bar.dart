import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/constants/app_icons.dart';

class ShellBottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const ShellBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  static const _icons = [
    AppIcons.calendar_1,
    AppIcons.recipe_book,
    AppIcons.shopping_list,
    AppIcons.cat_1,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHigh,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final isSelected = activeIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppDimensions.animationDuration,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.surface : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Icon(
                    _icons[index],
                    color: isSelected
                        ? colors.secondary
                        : colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
