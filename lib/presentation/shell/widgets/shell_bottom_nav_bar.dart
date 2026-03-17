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
              return _NavItem(
                icon: _icons[index],
                isSelected: activeIndex == index,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDimensions.animationDuration,
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.value = 0.0; // sofort deselektieren, kein Fade-out
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgAnim = ColorTween(
      begin: Colors.transparent,
      end: colors.surface,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    final iconAnim = ColorTween(
      begin: colors.onSurface.withValues(alpha: 0.6),
      end: colors.secondary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: bgAnim.value,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: Icon(widget.icon, color: iconAnim.value),
        ),
      ),
    );
  }
}
