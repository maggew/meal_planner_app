import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/recipe_suggestion/widgets/recipe_suggestion_body.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

@RoutePage()
class RecipeSuggestionPage extends ConsumerWidget {
  final DateTime referenceDate;
  final MealType mealType;
  final List<String> cookIds;

  const RecipeSuggestionPage({
    super.key,
    required this.referenceDate,
    required this.mealType,
    this.cookIds = const [],
  });

  void _showScoringInfo(
    BuildContext context, {
    required int rotationWeight,
    required int carbVarietyWeight,
  }) {
    final rTotal = rotationWeight + carbVarietyWeight;
    final rw = rTotal > 0 ? rotationWeight / rTotal * 0.5 : 0.0;
    final cw = rTotal > 0 ? carbVarietyWeight / rTotal * 0.5 : 0.0;
    final iw = 1.0 - rw - cw;

    String pct(double v) => '${(v * 100).round()}%';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Score-Berechnung'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScoreRow(
              label: 'Zutaten',
              weight: pct(iw),
              description: 'Wie viele eingegebene Zutaten im Rezept vorkommen',
            ),
            const SizedBox(height: 12),
            _ScoreRow(
              label: 'Rotation',
              weight: pct(rw),
              description: 'Wie lange das Rezept nicht gekocht wurde – '
                  'berücksichtigt auch bereits eingeplante Mahlzeiten (±14 Tage)',
            ),
            if (carbVarietyWeight > 0) ...[
              const SizedBox(height: 12),
              _ScoreRow(
                label: 'KH-Abwechslung',
                weight: pct(cw),
                description: 'Wie wenig die Kohlenhydrate mit den Mahlzeiten '
                    'der letzten und nächsten 3 Tage überlappen',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      sessionProvider.select((s) => s.group?.settings),
    );
    final rotationWeight = settings?.rotationWeight ?? 3;
    final carbVarietyWeight = settings?.carbVarietyWeight ?? 2;

    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => context.router.maybePop(),
        ),
        title: 'Vorschläge',
        actionsButtons: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Score-Berechnung',
            onPressed: () => _showScoringInfo(
              context,
              rotationWeight: rotationWeight,
              carbVarietyWeight: carbVarietyWeight,
            ),
          ),
        ],
      ),
      scaffoldBody: RecipeSuggestionBody(
        referenceDate: referenceDate,
        mealType: mealType,
        cookIds: cookIds,
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String weight;
  final String description;

  const _ScoreRow({
    required this.label,
    required this.weight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            weight,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
