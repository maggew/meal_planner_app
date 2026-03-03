import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_body.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleLogout() {
      final authController = ref.read(authControllerProvider.notifier);
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Ausloggen'),
          content: const Text('Möchtest du dich wirklich ausloggen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authController.logout();
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ausloggen'),
            ),
          ],
        ),
      );
    }

    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einstellungen",
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      scaffoldBody: SettingsBody(onLogout: handleLogout),
    );
  }
}
