import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

enum _PickerStep { recipe, cook }

class WeekplanRecipePicker extends ConsumerStatefulWidget {
  /// Called when both steps are complete.
  /// Exactly one of [recipeId] / [customName] is non-null; [cookId] is optional.
  final void Function(String? recipeId, String? customName, String? cookId)
      onSelected;

  /// In edit mode: show "Behalten: [label]" shortcut to skip recipe step.
  final String? initialLabel;

  /// In edit mode: pre-select this cook in step 2.
  final String? initialCookId;

  /// In edit mode: pre-fill free-text field.
  final String? initialCustomName;

  /// In edit mode: the existing recipe ID (kept when "Behalten" is tapped).
  final String? initialRecipeId;

  const WeekplanRecipePicker({
    super.key,
    required this.onSelected,
    this.initialLabel,
    this.initialCookId,
    this.initialCustomName,
    this.initialRecipeId,
  });

  @override
  ConsumerState<WeekplanRecipePicker> createState() =>
      _WeekplanRecipePickerState();
}

class _WeekplanRecipePickerState extends ConsumerState<WeekplanRecipePicker> {
  _PickerStep _step = _PickerStep.recipe;
  String _searchQuery = '';
  late final TextEditingController _customController;

  // Selection carried from step 1 to step 2
  String? _pendingRecipeId;
  String? _pendingCustomName;

  @override
  void initState() {
    super.initState();
    _customController =
        TextEditingController(text: widget.initialCustomName ?? '');
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  // ── Step transitions ──────────────────────────────────────────────────────

  void _goToCookStep(String? recipeId, String? customName) {
    setState(() {
      _pendingRecipeId = recipeId;
      _pendingCustomName = customName;
      _step = _PickerStep.cook;
    });
  }

  void _confirmWithCook(String? cookId) {
    Navigator.of(context).pop();
    widget.onSelected(_pendingRecipeId, _pendingCustomName, cookId);
  }

  void _submitCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    _goToCookStep(null, text);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => _step == _PickerStep.recipe
          ? _RecipeStep(
              scrollController: scrollController,
              customController: _customController,
              searchQuery: _searchQuery,
              onSearchChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              initialLabel: widget.initialLabel,
              onKeepCurrent: widget.initialLabel != null
                  ? () => _goToCookStep(
                        widget.initialRecipeId,
                        widget.initialCustomName,
                      )
                  : null,
              onRecipePicked: (id) => _goToCookStep(id, null),
              onCustomSubmit: _submitCustom,
              onCustomChanged: () => setState(() {}),
              customTextEmpty: _customController.text.trim().isEmpty,
            )
          : _CookStep(
              scrollController: scrollController,
              initialCookId: widget.initialCookId,
              onConfirm: _confirmWithCook,
              onBack: () => setState(() => _step = _PickerStep.recipe),
            ),
    );
  }
}

// ── Step 1: Recipe selection ──────────────────────────────────────────────────

class _RecipeStep extends ConsumerWidget {
  final ScrollController scrollController;
  final TextEditingController customController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? initialLabel;
  final VoidCallback? onKeepCurrent;
  final ValueChanged<String> onRecipePicked;
  final VoidCallback onCustomSubmit;
  final VoidCallback onCustomChanged;
  final bool customTextEmpty;

  const _RecipeStep({
    required this.scrollController,
    required this.customController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.initialLabel,
    required this.onKeepCurrent,
    required this.onRecipePicked,
    required this.onCustomSubmit,
    required this.onCustomChanged,
    required this.customTextEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final dao = ref.watch(recipeCacheDaoProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text('Mahlzeit planen', style: textTheme.titleSmall),
          ),

          // "Keep current" shortcut (edit mode only)
          if (initialLabel != null && onKeepCurrent != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: InkWell(
                onTap: onKeepCurrent,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Behalten: $initialLabel',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),

          if (initialLabel != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'oder ändern',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.15)),
                  ),
                ],
              ),
            ),

          // Free-text input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    decoration: InputDecoration(
                      hintText: 'Freitext (z. B. Reste) …',
                      prefixIcon: const Icon(Icons.edit_note),
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onCustomSubmit(),
                    onChanged: (_) => onCustomChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: customTextEmpty ? null : onCustomSubmit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    minimumSize: Size.zero,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 20),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.15)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'oder Rezept wählen',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.15)),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: false,
              decoration: const InputDecoration(
                hintText: 'Rezept suchen …',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(height: 8),

          // Recipe list
          Expanded(
            child: StreamBuilder<List<LocalRecipe>>(
              stream: dao.watchRecipesByGroup(groupId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recipes = snapshot.data!
                    .where((r) =>
                        searchQuery.isEmpty ||
                        r.name.toLowerCase().contains(searchQuery))
                    .toList();

                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Rezepte gefunden',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: recipes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      title: Text(recipe.name, style: textTheme.bodyMedium),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => onRecipePicked(recipe.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Cook selection ────────────────────────────────────────────────────

class _CookStep extends ConsumerWidget {
  final ScrollController scrollController;
  final String? initialCookId;
  final ValueChanged<String?> onConfirm;
  final VoidCallback onBack;

  const _CookStep({
    required this.scrollController,
    required this.initialCookId,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row with back button
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 20, 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: onBack,
                ),
                Expanded(
                  child:
                      Text('Wer kocht?', style: textTheme.titleSmall),
                ),
                TextButton(
                  onPressed: () => onConfirm(null),
                  child: const Text('Überspringen'),
                ),
              ],
            ),
          ),

          Expanded(
            child: membersAsync.when(
              data: (members) => ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: members
                    .map((user) => _MemberTile(
                          user: user,
                          isSelected: user.id == initialCookId,
                          onTap: () => onConfirm(user.id),
                        ))
                    .toList(),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberTile({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: user.imageUrl != null
            ? CachedNetworkImageProvider(user.imageUrl!)
            : null,
        child: user.imageUrl == null
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onPrimaryContainer),
              )
            : null,
      ),
      title: Text(user.name, style: textTheme.bodyMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
