import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_body.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late UserSettings newSettings;
  bool _isLoading = false;
  @override
  void initState() {
    final session = ref.read(sessionProvider);
    newSettings = session.settings ?? UserSettings.defaultSettings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: "Einstellungen",
        leading: IconButton(
          onPressed: () {
            context.router.pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        actionsButtons: [
          IconButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              final sessionNotifier = ref.read(sessionProvider.notifier);
              await sessionNotifier.changeSettings(newSettings);
              setState(() => _isLoading = false);
              context.router.pop();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      scaffoldBody: LoadingOverlay(
        isLoading: _isLoading,
        child: SettingsBody(
          newSettings: newSettings,
          onSettingsChanged: (settings) {
            setState(() => newSettings = settings);
          },
        ),
      ),
    );
  }
}
