import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class WeekplanRecipePicker extends ConsumerStatefulWidget {
  /// Called when the user finishes. Exactly one of [recipeId] / [customName]
  /// is non-null; [cookIds] may be empty.
  final void Function(String? recipeId, String? customName, List<String> cookIds)
      onSelected;

  /// Edit mode: show "Behalten: [label]" shortcut.
  final String? initialLabel;

  /// Edit mode: pre-select these cooks.
  final List<String> initialCookIds;

  /// Edit mode: pre-fill free-text field.
  final String? initialCustomName;

  /// Edit mode: the existing recipe ID (kept when "Behalten" is tapped).
  final String? initialRecipeId;

  /// The date being planned — shown as a subtitle.
  final DateTime? date;

  /// The meal type being planned — shown as a subtitle.
  final MealType? mealType;

  const WeekplanRecipePicker({
    super.key,
    required this.onSelected,
    this.initialLabel,
    this.initialCookIds = const [],
    this.initialCustomName,
    this.initialRecipeId,
    this.date,
    this.mealType,
  });

  @override
  ConsumerState<WeekplanRecipePicker> createState() =>
      _WeekplanRecipePickerState();
}

class _WeekplanRecipePickerState extends ConsumerState<WeekplanRecipePicker> {
  String _searchQuery = '';
  late final TextEditingController _customController;
  late final Set<String> _selectedCookIds;

  static const _weekdayLong = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag',
  ];
  static const _monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  String? get _subtitle {
    final d = widget.date;
    final m = widget.mealType;
    if (d == null && m == null) return null;
    final parts = <String>[];
    if (m != null) parts.add(m.displayName);
    if (d != null) {
      parts.add('${_weekdayLong[d.weekday - 1]}, ${d.day}. ${_monthNames[d.month - 1]}');
    }
    return parts.join(' • ');
  }

  @override
  void initState() {
    super.initState();
    _customController =
        TextEditingController(text: widget.initialCustomName ?? '');
    _selectedCookIds = widget.initialCookIds.toSet();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _confirm(String? recipeId, String? customName) {
    Navigator.of(context).pop();
    widget.onSelected(recipeId, customName, _selectedCookIds.toList());
  }

  void _submitCustom() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    _confirm(null, text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final dao = ref.watch(recipeCacheDaoProvider);
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadius),
            ),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
              child: Text('Mahlzeit planen', style: textTheme.titleSmall),
            ),
            if (_subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  _subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),

            // Cook picker
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text('Koch', style: textTheme.labelMedium),
            ),
            membersAsync.when(
              data: (members) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: members
                      .map((user) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _CookChip(
                              user: user,
                              isSelected: _selectedCookIds.contains(user.id),
                              onTap: () => setState(() {
                                if (_selectedCookIds.contains(user.id)) {
                                  _selectedCookIds.remove(user.id);
                                } else {
                                  _selectedCookIds.add(user.id);
                                }
                              }),
                            ),
                          ))
                      .toList(),
                ),
              ),
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Divider(
                  color: colorScheme.onSurface.withValues(alpha: 0.15)),
            ),

            // "Keep current" shortcut (edit mode only)
            if (widget.initialLabel != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: InkWell(
                  onTap: () =>
                      _confirm(widget.initialRecipeId, widget.initialCustomName),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius),
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
                            'Behalten: ${widget.initialLabel}',
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
            ],

            // Free-text input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      decoration: InputDecoration(
                        hintText: 'Freitext (z. B. Reste) …',
                        prefixIcon: const Icon(Icons.edit_note),
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitCustom(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _customController.text.trim().isEmpty
                        ? null
                        : _submitCustom,
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
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.15)),
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
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.15)),
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
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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
                          _searchQuery.isEmpty ||
                          r.name.toLowerCase().contains(_searchQuery))
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: recipes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return ListTile(
                        title: Text(recipe.name, style: textTheme.bodyMedium),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _confirm(recipe.id, null),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _CookChip extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _CookChip({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 22,
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
          ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
