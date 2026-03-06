import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class PlanRecipeSheet extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;

  const PlanRecipeSheet({
    super.key,
    required this.recipeId,
    required this.recipeName,
  });

  @override
  ConsumerState<PlanRecipeSheet> createState() => _PlanRecipeSheetState();
}

class _PlanRecipeSheetState extends ConsumerState<PlanRecipeSheet> {
  DateTime _selectedDate = DateTime.now();
  MealType? _selectedMealType;
  final Set<String> _selectedCookIds = {};

  static const _weekdayLong = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag',
  ];
  static const _monthNames = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  String get _formattedDate {
    final d = _selectedDate;
    return '${_weekdayLong[d.weekday - 1]}, ${d.day}. ${_monthNames[d.month - 1]}';
  }

  Future<void> _pickDate(WeekStartDay weekStartDay) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // Only override locale when Sunday start is explicitly requested;
      // the app-level locale (de) already gives Monday by default.
      builder: weekStartDay == WeekStartDay.sunday
          ? (context, child) => Localizations.override(
                context: context,
                locale: const Locale('en'),
                delegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: child!,
              )
          : null,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedMealType == null) return;

    final entries =
        ref.read(mealPlanStreamProvider(_selectedDate)).value ?? [];
    final existing =
        entries.where((e) => e.mealType == _selectedMealType).firstOrNull;

    if (existing != null) {
      final String existingName;
      if (existing.recipeId != null) {
        existingName = await ref.read(
                recipeNameProvider(existing.recipeId!).future) ??
            existing.recipeId!;
      } else {
        existingName = existing.customName ?? '–';
      }

      if (!mounted) return;
      final replace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Slot bereits belegt'),
          content: Text(
            '${_selectedMealType!.displayName} am $_formattedDate '
            'ist bereits belegt mit:\n\n„$existingName"\n\nErsetzen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ersetzen'),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
      await ref.read(mealPlanActionsProvider).updateEntry(
            existing.id,
            recipeId: widget.recipeId,
            cookIds: _selectedCookIds.toList(),
          );
    } else {
      await ref.read(mealPlanActionsProvider).addEntry(
            date: _selectedDate,
            mealType: _selectedMealType!,
            recipeId: widget.recipeId,
            cookIds: _selectedCookIds.toList(),
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final settings = ref.watch(groupSettingsProvider);
    final mealSlots = settings.defaultMealSlots;

    // Keep the stream alive while the sheet is open so _submit can read it
    ref.watch(mealPlanStreamProvider(_selectedDate));

    // Reset selection if the chosen meal type is no longer in the allowed slots
    if (_selectedMealType != null && !mealSlots.contains(_selectedMealType)) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _selectedMealType = null));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('Zum Wochenplan hinzufügen', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              widget.recipeName,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Date picker row
            Text('Tag', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDate(settings.weekStartDay),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(_formattedDate, style: textTheme.bodyMedium),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Meal type selector
            Text('Mahlzeit', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            SegmentedButton<MealType>(
              segments: mealSlots
                  .map((t) => ButtonSegment(
                        value: t,
                        label: Text(t.displayName),
                      ))
                  .toList(),
              selected: _selectedMealType != null ? {_selectedMealType!} : {},
              emptySelectionAllowed: true,
              onSelectionChanged: (set) =>
                  setState(() => _selectedMealType = set.firstOrNull),
            ),
            const SizedBox(height: 20),

            // Cook selector
            Text('Koch', style: textTheme.labelMedium),
            const SizedBox(height: 10),
            membersAsync.when(
              data: (members) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 6),
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
            const SizedBox(height: 28),

            // Submit
            ElevatedButton(
              onPressed: _selectedMealType != null ? _submit : null,
              child: const Text('Eintragen'),
            ),
          ],
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
