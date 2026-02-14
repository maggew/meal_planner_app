import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_body.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);

    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einstellungen",
        leading: IconButton(
          onPressed: () {
            context.router.pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        // actionsButtons: [
        //   IconButton(
        //     onPressed: () async {
        //       setState(() => _isLoading = true);
        //       final sessionNotifier = ref.read(sessionProvider.notifier);
        //       await sessionNotifier.changeSettings(newSettings);
        //       setState(() => _isLoading = false);
        //       context.router.pop();
        //     },
        //     icon: Icon(Icons.save),
        //   ),
        // ],
      ),
      scaffoldBody: SettingsBody(
        settings: settings,
        onSettingsChanged: (updated) {
          ref.read(userSettingsProvider.notifier).update(updated);
        },
      ),
    );
  }
}
