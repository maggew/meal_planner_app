import 'package:flutter/material.dart';

class AnalyticsConsentSheet extends StatelessWidget {
  const AnalyticsConsentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App-Analyse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Darf die App anonymisierte Nutzungsdaten senden? '
              'Dies hilft uns, die App zu verbessern. '
              'Es werden keine persönlichen Inhalte übermittelt.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Ablehnen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Akzeptieren'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
