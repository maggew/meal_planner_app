import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';
import 'package:meal_planner/presentation/subscription/widgets/paywall_sheet.dart';

class SubscriptionSection extends ConsumerWidget {
  const SubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return subscriptionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (subscription) {
        final isPremium = subscription.isPremium;
        final expiresAt = subscription.expiresAt;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.workspace_premium : Icons.star_border,
                  color: isPremium ? colors.primary : colors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Abo',
                  style: textTheme.titleSmall,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? colors.primaryContainer
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPremium ? 'Premium' : 'Kostenlos',
                    style: textTheme.labelSmall?.copyWith(
                      color: isPremium
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (isPremium && expiresAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Bis ${expiresAt.day.toString().padLeft(2, '0')}.${expiresAt.month.toString().padLeft(2, '0')}.${expiresAt.year}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (!isPremium) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => showPaywallSheet(context),
                  child: const Text('Premium holen'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
