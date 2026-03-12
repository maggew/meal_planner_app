import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Profil",
        automaticallyImplyLeading: false,
        actionsButtons: [
          IconButton(
            key: const ValueKey("settings"),
            onPressed: () => context.router.root.push(const SettingsRoute()),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      scaffoldBody: const ProfileBody(),
    );
  }
}
