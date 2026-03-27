import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  static const _privacyPolicyUrl =
      'https://maggew.github.io/meal_planner_app/de.html';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rechtliches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.privacy_tip_outlined, color: colorScheme.primary),
          title: const Text('Datenschutzerklärung'),
          trailing: Icon(Icons.open_in_new, size: 18, color: colorScheme.onSurfaceVariant),
          onTap: () => _openPrivacyPolicy(),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.article_outlined, color: colorScheme.primary),
          title: const Text('Open Source Lizenzen'),
          trailing: Icon(Icons.chevron_right, size: 18, color: colorScheme.onSurfaceVariant),
          onTap: () => context.router.push(LicensesRoute()),
        ),
      ],
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
