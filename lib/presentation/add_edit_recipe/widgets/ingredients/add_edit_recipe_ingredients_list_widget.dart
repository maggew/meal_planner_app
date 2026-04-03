import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/add_edit_recipe_instructions.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/flat_list_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients/add_edit_recipe_ingredient_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients/add_edit_recipe_ingredients_input_card.dart';
import 'package:meal_planner/presentation/add_edit_recipe/widgets/ingredients/add_edit_recipe_section_header_item.dart';
import 'package:meal_planner/services/providers/recipe/add_edit_recipe_ingredients_provider.dart';
import 'package:meal_planner/services/providers/recipe/linked_recipe_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

class AddEditRecipeIngredientsListWidget extends ConsumerWidget {
  final AddEditRecipeIngredientsProvider ingredientsProvider;
  final String? currentRecipeId;
  const AddEditRecipeIngredientsListWidget(
      {super.key, required this.ingredientsProvider, this.currentRecipeId});

  Future<void> _showRecipeLinkDialog(BuildContext context, WidgetRef ref) async {
    final state = ref.read(ingredientsProvider);
    final excludeIds = <String>{
      if (currentRecipeId != null) currentRecipeId!,
      ...state.sections
          .where((s) => s.linkedRecipeId != null)
          .map((s) => s.linkedRecipeId!),
    };
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RecipeLinkSearchSheet(excludeIds: excludeIds),
    );
    if (recipe != null && context.mounted) {
      ref.read(ingredientsProvider.notifier).addLinkedSection(
            recipe.id!,
            recipe.name,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ingredientsProvider);

    final List<FlatListItem> flatItems = [];
    for (int sectionIndex = 0;
        sectionIndex < state.sections.length;
        sectionIndex++) {
      final section = state.sections[sectionIndex];

      flatItems.add(
          FlatListItem.header(sectionIndex: sectionIndex, section: section));

      // Linked sections have no own ingredients or add button
      if (!section.isLinked) {
        for (int itemIndex = 0;
            itemIndex < section.items.length;
            itemIndex++) {
          final IngredientFormItem item = section.items[itemIndex];
          flatItems.add(FlatListItem.ingredient(
              sectionIndex: sectionIndex, itemIndex: itemIndex, item: item));
        }

        // Button zum Hinzufügen eines neuen Ingredients in dieser Sektion
        flatItems.add(FlatListItem.addButton(sectionIndex: sectionIndex));
      }
    }
    final int listLength = flatItems.length;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          ReorderableListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: listLength,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    elevation: 8,
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    child: child,
                  );
                },
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              ref.read(ingredientsProvider.notifier).reorderIngredient(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                    flatItems: flatItems,
                  );
            },
            itemBuilder: (BuildContext, index) {
              final itemData = flatItems[index];
              switch (itemData.type) {
                case FlatListItemType.header:
                  final section = itemData.section!;

                  // Linked section: simplified non-editable header
                  if (section.isLinked) {
                    final sectionCount = state.sections.length;
                    final canMoveUp = itemData.sectionIndex > 0;
                    final canMoveDown =
                        itemData.sectionIndex < sectionCount - 1;
                    final asyncLinked = ref.watch(
                        linkedRecipeProvider(section.linkedRecipeId!));
                    final isBroken = asyncLinked.hasValue &&
                        asyncLinked.value == null;
                    return Padding(
                      key: ValueKey('section_${itemData.sectionIndex}'),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBroken
                              ? colorScheme.errorContainer
                              : colorScheme.secondaryContainer,
                          borderRadius: AppDimensions.borderRadiusAll,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(
                                  isBroken ? Icons.link_off : Icons.link,
                                  size: 18,
                                  color: isBroken
                                      ? colorScheme.error
                                      : colorScheme.primary),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      section.titleController.text,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                        color: isBroken
                                            ? colorScheme.error
                                            : colorScheme.primary,
                                      ),
                                    ),
                                    if (isBroken)
                                      Text(
                                        'Rezept nicht mehr verfügbar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: colorScheme.error,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _handleDeletePressed(
                                  context,
                                  ref,
                                  ingredientsProvider,
                                  itemData.sectionIndex),
                              icon: Icon(Icons.delete,
                                  color: colorScheme.onSecondaryContainer),
                            ),
                            if (canMoveUp || canMoveDown)
                              PopupMenuButton<String>(
                                icon: Icon(Icons.swap_vert,
                                    color: colorScheme.onSecondaryContainer),
                                padding: EdgeInsets.zero,
                                onSelected: (value) {
                                  if (value == 'up') {
                                    ref
                                        .read(ingredientsProvider.notifier)
                                        .moveSectionUp(itemData.sectionIndex);
                                  }
                                  if (value == 'down') {
                                    ref
                                        .read(ingredientsProvider.notifier)
                                        .moveSectionDown(
                                            itemData.sectionIndex);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (canMoveUp)
                                    const PopupMenuItem(
                                      value: 'up',
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_upward, size: 20),
                                          SizedBox(width: 8),
                                          Text('Nach oben'),
                                        ],
                                      ),
                                    ),
                                  if (canMoveDown)
                                    const PopupMenuItem(
                                      value: 'down',
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_downward, size: 20),
                                          SizedBox(width: 8),
                                          Text('Nach unten'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  final bool sectionHasNoIngredient =
                      index + 1 < flatItems.length &&
                      flatItems[index + 1].type == FlatListItemType.addButton;
                  final sectionCount = state.sections.length;
                  return AddEditRecipeSectionHeaderItem(
                    key: ValueKey('section_${itemData.sectionIndex}'),
                    titleController: section.titleController,
                    isEditable: section.isEditable,
                    sectionHasNoIngredient: sectionHasNoIngredient,
                    shouldRequestFocus: section.shouldRequestFocus,
                    isFirstSection: itemData.sectionIndex == 0,
                    onMoveUpPressed: itemData.sectionIndex > 0
                        ? () => ref
                            .read(ingredientsProvider.notifier)
                            .moveSectionUp(itemData.sectionIndex)
                        : null,
                    onMoveDownPressed:
                        itemData.sectionIndex < sectionCount - 1
                            ? () => ref
                                .read(ingredientsProvider.notifier)
                                .moveSectionDown(itemData.sectionIndex)
                            : null,
                    onDeletePressed: () => _handleDeletePressed(context, ref,
                        ingredientsProvider, itemData.sectionIndex),
                    onEditPressed: () {
                      ref
                          .read(ingredientsProvider.notifier)
                          .editSectionTitle(itemData.sectionIndex);
                    },
                    onConfirmPressed: () {
                      FocusScope.of(context).unfocus();
                      ref
                          .read(ingredientsProvider.notifier)
                          .confirmSectionTitle(itemData.sectionIndex);
                    },
                  );
                case FlatListItemType.ingredient:
                  final item = itemData.item;
                  //final isFirstItem = itemData.itemIndex == 0;
                  final isFinalItem = itemData.itemIndex ==
                      state.sections[itemData.sectionIndex].items.length - 1;

                  if (item!.isEditable) {
                    return AddEditRecipeIngredientsInputCard(
                      key: ValueKey(item.id),
                      item: item,
                      isFinalItem: isFinalItem,
                      onDelete: () => ref
                          .read(ingredientsProvider.notifier)
                          .deleteIngredient(index),
                      onChecked: () {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(ingredientsProvider.notifier)
                            .confirmIngredient(index);
                      },
                      onUnitChanged: (unit) {
                        ref
                            .read(ingredientsProvider.notifier)
                            .changeUnit(flatIndex: index, unit: unit);
                      },
                    );
                  }

                  // Nicht editierbar - normales Display Widget
                  return AddEditRecipeIngredientItem(
                    key: ValueKey(item),
                    flatIndex: index,
                    itemData: itemData,
                    isFinalItem: isFinalItem,
                    ingredientsProvider: ingredientsProvider,
                  );
                case FlatListItemType.addButton:
                  return ListTile(
                    key: ValueKey('add_btn_${itemData.sectionIndex}'),
                    dense: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Icon(Icons.add, color: colorScheme.primary),
                        Text('Zutat hinzufügen'),
                      ],
                    ),
                    onTap: () {
                      ref
                          .read(ingredientsProvider.notifier)
                          .addIngredient(itemData.sectionIndex);
                    },
                  );
              }
            },
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(ingredientsProvider.notifier).addSection();
                },
                icon: Icon(Icons.add),
                label: Text('Neue Sektion'),
              ),
              TextButton.icon(
                onPressed: () => _showRecipeLinkDialog(context, ref),
                icon: Icon(Icons.link),
                label: Text('Rezept verknüpfen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _handleDeletePressed(
  BuildContext context,
  WidgetRef ref,
  AddEditRecipeIngredientsProvider ingredientsProvider,
  int sectionIndex,
) async {
  // canRequestFocus = false auf dem Instructions-FocusNode setzen (synchron),
  // damit Flutter beim Dialog-Close den Fokus dort nicht wiederherstellen kann.
  excludeInstructionsFocusNotifier.value = true;

  // 1. Bestätigungsdialog abholen
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sektion löschen'),
      content: const Text(
          'Möchtest du wirklich die Sektion löschen? \nDie Zutaten werden nach oben verschoben!'),
      actions: [
        TextButton(
          onPressed: () => context.router.maybePop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => context.router.maybePop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    ref.read(ingredientsProvider.notifier).removeSection(sectionIndex);
  }

  // Nach Ablauf der Dialog-Pop-Animation zurücksetzen (~300ms).
  Future.delayed(const Duration(milliseconds: 350), () {
    excludeInstructionsFocusNotifier.value = false;
  });
}

class _RecipeLinkSearchSheet extends ConsumerStatefulWidget {
  final Set<String> excludeIds;
  const _RecipeLinkSearchSheet({this.excludeIds = const {}});

  @override
  ConsumerState<_RecipeLinkSearchSheet> createState() =>
      _RecipeLinkSearchSheetState();
}

class _RecipeLinkSearchSheetState
    extends ConsumerState<_RecipeLinkSearchSheet> {
  final _searchController = TextEditingController();
  List<Recipe> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    try {
      final repo = ref.read(recipeRepositoryProvider);
      final results = await repo.searchRecipes(query.trim());
      if (mounted) {
        setState(() => _results = results
            .where((r) => r.id == null || !widget.excludeIds.contains(r.id))
            .toList());
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rezept verknüpfen', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rezept suchen...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.borderRadiusAll,
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.length < 2
                            ? 'Mindestens 2 Zeichen eingeben'
                            : 'Keine Rezepte gefunden',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final recipe = _results[index];
                        return ListTile(
                          leading: Icon(Icons.restaurant_menu,
                              color: colorScheme.primary),
                          title: Text(recipe.name),
                          onTap: () => Navigator.of(context).pop(recipe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

