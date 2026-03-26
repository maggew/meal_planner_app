import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/presentation/settings/widgets/account_section.dart';
import 'package:meal_planner/presentation/settings/widgets/group_settings_section.dart';
import 'package:meal_planner/presentation/settings/widgets/subscription_section.dart';
import 'package:meal_planner/presentation/settings/widgets/legal_section.dart';
import 'package:meal_planner/presentation/settings/widgets/user_settings_section.dart';

class SettingsBody extends StatelessWidget {
  final VoidCallback onLogout;
  final void Function(bool) onAccountEditingChanged;
  final void Function(bool) onGroupEditingChanged;

  const SettingsBody({
    super.key,
    required this.onLogout,
    required this.onAccountEditingChanged,
    required this.onGroupEditingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          GlassCard(
            child: Column(
              children: [
                AccountSection(onEditingChanged: onAccountEditingChanged),
                const Divider(height: 32),
                const UserSettingsSection(),
              ],
            ),
          ),
          const GlassCard(
            child: SubscriptionSection(),
          ),
          GlassCard(
            child: GroupSettingsSection(
                onEditingChanged: onGroupEditingChanged),
          ),
          const GlassCard(
            child: LegalSection(),
          ),
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
