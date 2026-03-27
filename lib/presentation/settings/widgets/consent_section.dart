import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/consent_provider.dart';

class ConsentSection extends ConsumerWidget {
  const ConsentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final analyticsEnabled = ref.watch(analyticsConsentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datenschutz',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary:
              Icon(Icons.analytics_outlined, color: colorScheme.primary),
          title: const Text('App-Analyse'),
          subtitle: const Text('Anonymisierte Nutzungsdaten senden'),
          value: analyticsEnabled,
          onChanged: (value) =>
              ref.read(analyticsConsentProvider.notifier).setConsent(value),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(Icons.ads_click_outlined, color: colorScheme.primary),
          title: const Text('Werbe-Einstellungen'),
          subtitle: const Text('Einwilligung für personalisierte Werbung'),
          trailing: Icon(Icons.chevron_right,
              size: 18, color: colorScheme.onSurfaceVariant),
          onTap: () => _openAdsConsent(ref),
        ),
      ],
    );
  }

  Future<void> _openAdsConsent(WidgetRef ref) async {
    final service = ref.read(consentServiceProvider);
    await service.resetAdsConsent();
    await service.requestAdsConsent();
  }
}
