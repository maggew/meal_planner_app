import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/enums/carb_tag.dart';
import 'package:meal_planner/services/providers/recipe/carb_tag_selection_provider.dart';

class CarbTagSelection extends ConsumerWidget {
  const CarbTagSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(carbTagSelectionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final tagsToShow = CarbTag.values.where((t) => t != CarbTag.keine).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kohlenhydrate',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: tagsToShow.map((tag) {
            final isSelected = selectedTags.contains(tag.value);
            return FilterChip(
              label: Text(tag.displayName),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(carbTagSelectionProvider.notifier).toggle(tag.value),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
