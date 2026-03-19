import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/subscription/widgets/paywall_sheet.dart';

class PromoCardWidget extends StatelessWidget {
  final double height;
  const PromoCardWidget({super.key, this.height = 120});

  static const _tips = [
    _Tip(
      icon: Icons.auto_awesome,
      text: 'Lass dir Rezepte vorschlagen — basierend auf deinen Zutaten!',
    ),
    _Tip(
      icon: Icons.restaurant_menu,
      text: 'Langdrücken auf ein Rezept, um es direkt einzuplanen.',
    ),
    _Tip(
      icon: Icons.shopping_cart_outlined,
      text: 'Zutaten direkt aus dem Rezept zur Einkaufsliste hinzufügen.',
    ),
    _Tip(
      icon: Icons.timer_outlined,
      text: 'Im Kochmodus kannst du Timer für jeden Schritt setzen.',
    ),
    _Tip(
      icon: Icons.group_outlined,
      text: 'Teile deine Gruppe — plant und kocht gemeinsam!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final showUpsell = Random().nextBool();
    return showUpsell
        ? _PremiumUpsellCard(height: height)
        : _FeatureTipCard(height: height, tip: _tips[Random().nextInt(_tips.length)]);
  }
}

class _PremiumUpsellCard extends StatelessWidget {
  final double height;
  const _PremiumUpsellCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => showPaywallSheet(context),
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.85),
          borderRadius: AppDimensions.borderRadiusAll,
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: colors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Werbefrei mit Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keine Werbung & unbegrenzte Vorschläge',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.onPrimaryContainer.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTipCard extends StatelessWidget {
  final double height;
  final _Tip tip;
  const _FeatureTipCard({required this.height, required this.tip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: AppDimensions.borderRadiusAll,
      ),
      child: Row(
        children: [
          Icon(
            tip.icon,
            color: colors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String text;
  const _Tip({required this.icon, required this.text});
}
