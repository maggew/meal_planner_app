import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/constants/app_icons.dart';
import 'package:meal_planner/presentation/group_onboarding/widgets/group_onboarding_button.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

class GroupOnboardingBody extends StatelessWidget {
  const GroupOnboardingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GroupOnboardingButton(
                icon: AppIcons.add,
                label: 'Gruppe erstellen',
                onPressed: () => context.router.push(const CreateGroupRoute()),
              ),
              const SizedBox(height: 16),
              GroupOnboardingButton(
                icon: AppIcons.cheers,
                label: 'Gruppe beitreten',
                onPressed: () => context.router.push(const JoinGroupRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
