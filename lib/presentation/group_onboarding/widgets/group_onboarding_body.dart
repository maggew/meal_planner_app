import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class GroupOnboardingBody extends StatelessWidget {
  const GroupOnboardingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OnboardingButton(
          icon: AppIcons.add,
          iconPadding: const EdgeInsets.only(left: 13),
          iconSize: 80,
          label: 'Gruppe erstellen',
          colorScheme: colorScheme,
          onPressed: () => context.router.push(const CreateGroupRoute()),
        ),
        const SizedBox(width: 20),
        _OnboardingButton(
          icon: AppIcons.cheers,
          iconSize: 75,
          label: 'Gruppe beitreten',
          colorScheme: colorScheme,
          onPressed: () => context.router.push(const JoinGroupRoute()),
        ),
      ],
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final IconData icon;
  final EdgeInsetsGeometry? iconPadding;
  final double iconSize;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  const _OnboardingButton({
    required this.icon,
    this.iconPadding,
    required this.iconSize,
    required this.label,
    required this.colorScheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 140,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          disabledForegroundColor:
              colorScheme.primaryContainer.withValues(alpha: 0.38),
          disabledBackgroundColor:
              colorScheme.primaryContainer.withValues(alpha: 0.12),
          elevation: 10,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: iconPadding ?? EdgeInsets.zero,
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 15),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
