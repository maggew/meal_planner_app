import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/settings/widgets/settings_body.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _accountEditing = false;
  bool _groupEditing = false;

  bool get _isAnyEditing => _accountEditing || _groupEditing;

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Änderungen verwerfen?'),
        content: const Text(
          'Du hast ungespeicherte Änderungen. Diese gehen verloren, wenn du die Seite verlässt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bleiben'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    if (!_isAnyEditing) {
      context.router.pop();
      return;
    }
    final confirmed = await _confirmDiscard();
    if (confirmed && mounted) context.router.pop();
  }

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAnyEditing,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final confirmed = await _confirmDiscard();
          if (confirmed && mounted) context.router.pop();
        }
      },
      child: AppBackground(
        scaffoldAppBar: CommonAppbar(
          title: 'Einstellungen',
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.chevron_left),
          ),
        ),
        scaffoldBody: SettingsBody(
          onLogout: handleLogout,
          onAccountEditingChanged: (v) => setState(() => _accountEditing = v),
          onGroupEditingChanged: (v) => setState(() => _groupEditing = v),
        ),
      ),
    );
  }
}
