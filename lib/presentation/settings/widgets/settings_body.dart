import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/settings/widgets/account_section.dart';
import 'package:meal_planner/presentation/settings/widgets/group_settings_section.dart';
import 'package:meal_planner/presentation/settings/widgets/user_settings_section.dart';

class SettingsBody extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsBody({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AccountSection(),
          const Divider(height: 32),
          const UserSettingsSection(),
          const Divider(height: 32),
          const GroupSettingsSection(),
          const Divider(height: 32),
          OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Ausloggen'),
          ),
        ],
      ),
    );
  }
}
