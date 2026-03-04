import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/recipe_suggestion/widgets/recipe_suggestion_body.dart';

@RoutePage()
class RecipeSuggestionPage extends StatelessWidget {
  const RecipeSuggestionPage({super.key});

  void _showScoringInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Score-Berechnung'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScoreRow(
                label: 'Zutaten',
                weight: '50%',
                description:
                    'Wie viele eingegebene Zutaten im Rezept vorkommen'),
            SizedBox(height: 12),
            _ScoreRow(
                label: 'Rotation',
                weight: '30%',
                description:
                    'Wie lange das Rezept nicht gekocht wurde (max. 14 Tage)'),
            SizedBox(height: 12),
            _ScoreRow(
                label: 'KH-Abwechslung',
                weight: '20%',
                description:
                    'Wie wenig die Kohlenhydrate mit den letzten 3 Tagen überlappen'),
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
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(
        title: 'Vorschläge',
        actionsButtons: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Score-Berechnung',
            onPressed: () => _showScoringInfo(context),
          ),
        ],
      ),
      scaffoldBody: const RecipeSuggestionBody(),
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
              Text(description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      )),
            ],
          ),
        ),
      ],
    );
  }
}
