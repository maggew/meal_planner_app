import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/entities/slot_drag_payload.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/presentation/detailed_weekplan/widgets/weekplan_recipe_picker.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_clipboard_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_provider.dart';
import 'package:meal_planner/services/providers/meal_plan/slot_drag_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';

class WeekplanDayCard extends ConsumerWidget {
  final DateTime date;

  const WeekplanDayCard({super.key, required this.date});

  /// Minimum rendered height: vertical margin (14) + vertical padding (36) + header row (~20)
  static const double minHeight = 70;

  static const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  static const _mealIcons = {
    MealType.breakfast: Icons.wb_sunny_outlined,
    MealType.lunch: Icons.lunch_dining,
    MealType.dinner: Icons.nights_stay_outlined,
  };

  Future<void> _handleDrop(
    BuildContext context,
    WidgetRef ref,
    SlotDragPayload payload,
    MealType targetMealType,
    List<MealPlanEntry> targetEntries,
  ) async {
    // No-op when the user drops the slot back onto itself.
    if (payload.date == date && payload.mealType == targetMealType) return;

    if (targetEntries.isEmpty) {
      final actions = ref.read(mealPlanActionsProvider);
      var allMoved = true;
      for (final entry in payload.entries) {
        final ok = await actions.moveEntry(entry.id,
            date: date, mealType: targetMealType);
        if (!ok) allMoved = false;
      }
      if (!allMoved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Eintrag wurde inzwischen geändert. Bitte erneut versuchen.'),
          ),
        );
      }
      return;
    }

    _showOccupiedTargetDialog(
        context, ref, payload, targetMealType, targetEntries);
  }

  Future<void> _showOccupiedTargetDialog(
    BuildContext context,
    WidgetRef ref,
    SlotDragPayload payload,
    MealType targetMealType,
    List<MealPlanEntry> targetEntries,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
            'Hier liegt bereits ein Eintrag. Was möchtest du tun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('append'),
            child: const Text('Hinzufügen'),
          ),
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(ctx).pop('swap'),
            child: const Text('Tauschen'),
          ),
        ],
      ),
    );

    if (choice == null || choice == 'cancel') return;

    final actions = ref.read(mealPlanActionsProvider);
    if (choice == 'append') {
      for (final entry in payload.entries) {
        actions.moveEntry(entry.id, date: date, mealType: targetMealType);
      }
    } else if (choice == 'swap') {
      for (final entry in payload.entries) {
        actions.moveEntry(entry.id, date: date, mealType: targetMealType);
      }
      for (final entry in targetEntries) {
        actions.moveEntry(entry.id,
            date: payload.date, mealType: payload.mealType);
      }
    }
  }

  void _pasteEntry(WidgetRef ref, MealType targetType) {
    final clipboard = ref.read(mealPlanClipboardProvider);
    if (clipboard == null) return;
    ref.read(mealPlanActionsProvider).addEntry(
          date: date,
          mealType: targetType,
          recipeId: clipboard.entry.recipeId,
          customName: clipboard.entry.customName,
          cookIds: clipboard.entry.cookIds,
        );
    if (clipboard.isCut) {
      ref.read(mealPlanActionsProvider).removeEntry(clipboard.entry.id);
    }
    ref.read(mealPlanClipboardProvider.notifier).clear();
  }

  void _openAddPicker(BuildContext context, WidgetRef ref, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WeekplanRecipePicker(
        date: date,
        mealType: mealType,
        onSelected: (recipeId, customName, cookIds) {
          ref.read(mealPlanActionsProvider).addEntry(
                date: date,
                mealType: mealType,
                recipeId: recipeId,
                customName: customName,
                cookIds: cookIds,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final entriesAsync = ref.watch(mealPlanStreamProvider(date));
    final entries = entriesAsync.value ?? [];
    final mealSlots = ref.watch(groupSettingsProvider).defaultMealSlots;
    final hasAnyEntry = entries.any((e) => mealSlots.contains(e.mealType));
    final clipboard = ref.watch(mealPlanClipboardProvider);
    final isDragging = ref.watch(isDraggingSlotProvider);
    // Empty days stay compact even during drag — the compact "+" icons
    // themselves act as drop targets, so the card doesn't resize on drag
    // start.
    final expandEmptyDay = hasAnyEntry;

    final dayLabel = _weekdayShort[date.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
        borderColor: isToday ? colorScheme.secondary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Row(
                  children: [
                    Text(
                      '$dayLabel, ${date.day}.${date.month}.',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (!expandEmptyDay)
                      ...mealSlots.map(
                        (type) => DragTarget<SlotDragPayload>(
                          onAcceptWithDetails: (details) => _handleDrop(
                              context, ref, details.data, type, const []),
                          builder: (ctx, candidate, rejected) =>
                              _CompactAddButton(
                            key: ValueKey('compact-add-${type.name}'),
                            icon: _mealIcons[type]!,
                            onTap: () => _openAddPicker(context, ref, type),
                            isHovering: candidate.isNotEmpty,
                          ),
                        ),
                      ),
                  ],
                ),
                if (expandEmptyDay) ...[
                  const SizedBox(height: 14),
                  ...mealSlots.expand((type) {
                    final slotEntries =
                        entries.where((e) => e.mealType == type).toList();

                    if (slotEntries.isEmpty) {
                      return [
                        DragTarget<SlotDragPayload>(
                          onAcceptWithDetails: (details) => _handleDrop(
                              context, ref, details.data, type, slotEntries),
                          builder: (ctx, candidate, rejected) =>
                              _SlotDropZone(
                            isDragging: isDragging,
                            isHovering: candidate.isNotEmpty,
                            child: _EmptySlotRow(
                              key: ValueKey('empty-slot-${type.name}'),
                              icon: _mealIcons[type]!,
                              onTap: () => _openAddPicker(context, ref, type),
                              onPaste: clipboard != null
                                  ? () => _pasteEntry(ref, type)
                                  : null,
                            ),
                          ),
                        ),
                      ];
                    }

                    final slotColumn = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MealRow(
                            entry: slotEntries.first,
                            icon: _mealIcons[type]!,
                            date: date),
                        for (int i = 1; i < slotEntries.length; i++)
                          _MealRow(
                              entry: slotEntries[i],
                              icon: _mealIcons[type]!,
                              date: date,
                              showIcon: false),
                      ],
                    );
                    final payload = SlotDragPayload(
                      date: date,
                      mealType: type,
                      entries: slotEntries,
                    );
                    return [
                      DragTarget<SlotDragPayload>(
                        onAcceptWithDetails: (details) => _handleDrop(
                            context, ref, details.data, type, slotEntries),
                        builder: (ctx, candidate, rejected) => _SlotDropZone(
                          isDragging: isDragging,
                          isHovering: candidate.isNotEmpty,
                          child: LongPressDraggable<SlotDragPayload>(
                            data: payload,
                            onDragStarted: () => ref
                                .read(isDraggingSlotProvider.notifier)
                                .value = true,
                            onDragEnd: (_) => ref
                                .read(isDraggingSlotProvider.notifier)
                                .value = false,
                            feedback: _SlotDragFeedback(child: slotColumn),
                            childWhenDragging:
                                Opacity(opacity: 0.35, child: slotColumn),
                            child: slotColumn,
                          ),
                        ),
                      ),
                      _AddMoreRow(
                        onTap: () => _openAddPicker(context, ref, type),
                        onPaste: clipboard != null
                            ? () => _pasteEntry(ref, type)
                            : null,
                      ),
                    ];
                  }),
                ],
              ],
            ),
          ),
    );
  }
}

void _showPasteOrNewModal(
  BuildContext context, {
  required VoidCallback onPaste,
  required VoidCallback onAddNew,
}) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.content_paste_outlined),
            title: const Text('Einfügen'),
            onTap: () {
              Navigator.pop(ctx);
              onPaste();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Neuer Eintrag'),
            onTap: () {
              Navigator.pop(ctx);
              onAddNew();
            },
          ),
        ],
      ),
    ),
  );
}

class _CompactAddButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isHovering;

  const _CompactAddButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isHovering
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.35);
    final bgColor = isHovering
        ? colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;
    final borderColor = isHovering
        ? colorScheme.primary.withValues(alpha: 0.9)
        : colorScheme.primary.withValues(alpha: 0.25);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: isHovering ? 2 : 1,
          color: borderColor,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: iconColor,
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onPaste;

  const _EmptySlotRow(
      {super.key, required this.icon, required this.onTap, this.onPaste});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        if (onPaste != null) {
          _showPasteOrNewModal(context, onPaste: onPaste!, onAddNew: onTap);
        } else {
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon,
                size: 20, color: colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(width: 8),
            Icon(
              onPaste != null ? Icons.content_paste_outlined : Icons.add,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends ConsumerWidget {
  final MealPlanEntry entry;
  final IconData icon;
  final DateTime date;
  final bool showIcon;

  const _MealRow({
    required this.entry,
    required this.icon,
    required this.date,
    this.showIcon = true,
  });

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset globalPosition,
    String? displayName,
  ) async {
    final size = MediaQuery.sizeOf(context);
    final dx = globalPosition.dx;
    final dy = globalPosition.dy;
    final isRecipe = entry.recipeId != null;
    final editLabel = isRecipe ? 'Rezept bearbeiten' : 'Bearbeiten';

    final result = await showMenu<String>(
      context: context,
      position:
          RelativeRect.fromLTRB(dx, dy, size.width - dx, size.height - dy),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: _PopupRow(icon: Icons.edit_outlined, label: editLabel),
        ),
        if (isRecipe)
          const PopupMenuItem(
            value: 'navigate',
            child: _PopupRow(
              icon: Icons.menu_book_outlined,
              label: 'Zum Rezept',
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'cut',
          child: _PopupRow(icon: Icons.content_cut, label: 'Ausschneiden'),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: _PopupRow(icon: Icons.content_copy, label: 'Kopieren'),
        ),
      ],
    );
    if (!context.mounted) return;
    switch (result) {
      case 'edit':
        _openEditPicker(context, ref, displayName);
      case 'navigate':
        context.router.root
            .push(ShowRecipeRoute(recipeId: entry.recipeId!));
      case 'copy':
        ref
            .read(mealPlanClipboardProvider.notifier)
            .copy(entry, displayName: displayName);
      case 'cut':
        ref
            .read(mealPlanClipboardProvider.notifier)
            .cut(entry, displayName: displayName);
    }
  }

  void _openEditPicker(
    BuildContext context,
    WidgetRef ref,
    String? displayName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WeekplanRecipePicker(
        date: date,
        mealType: entry.mealType,
        initialLabel: displayName,
        initialRecipeId: entry.recipeId,
        initialCustomName: entry.customName,
        initialCookIds: entry.cookIds,
        onSelected: (recipeId, customName, cookIds) {
          ref.read(mealPlanActionsProvider).updateEntry(
                entry.id,
                recipeId: recipeId,
                customName: customName,
                cookIds: cookIds,
              );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text('Diesen Eintrag wirklich entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(mealPlanActionsProvider).removeEntry(entry.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String? displayName;
    if (entry.recipeId != null) {
      final nameAsync = ref.watch(recipeNameProvider(entry.recipeId!));
      displayName = nameAsync.value;
    } else {
      displayName = entry.customName;
    }

    final clipboard = ref.watch(mealPlanClipboardProvider);
    final isCut = clipboard?.isCut == true && clipboard?.entry.id == entry.id;

    return Opacity(
      opacity: isCut ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: () {
          final box = context.findRenderObject() as RenderBox?;
          final position = box != null
              ? box.localToGlobal(box.size.center(Offset.zero))
              : Offset.zero;
          _showContextMenu(context, ref, position, displayName);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showIcon)
                Icon(icon, size: 20, color: colorScheme.primary)
              else
                const SizedBox(width: 20),
              if (entry.cookIds.isNotEmpty) ...[
                const SizedBox(width: 6),
                _CookAvatarStack(cookIds: entry.cookIds),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayName ?? '…',
                  style: textTheme.bodyLarge?.copyWith(
                    color: entry.recipeId != null
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (entry.recipeId != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.menu_book_outlined,
                  size: 15,
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showDeleteDialog(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMoreRow extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onPaste;

  const _AddMoreRow({required this.onTap, this.onPaste});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        if (onPaste != null) {
          _showPasteOrNewModal(context, onPaste: onPaste!, onAddNew: onTap);
        } else {
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 20),
            const SizedBox(width: 8),
            Icon(
              onPaste != null ? Icons.content_paste_outlined : Icons.add,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDropZone extends StatelessWidget {
  final bool isDragging;
  final bool isHovering;
  final Widget child;

  const _SlotDropZone({
    required this.isDragging,
    required this.isHovering,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = !isDragging
        ? Colors.transparent
        : isHovering
            ? colorScheme.primary.withValues(alpha: 0.9)
            : colorScheme.primary.withValues(alpha: 0.25);
    final bgColor = isHovering
        ? colorScheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: isHovering ? 2 : 1,
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}

class _SlotDragFeedback extends StatelessWidget {
  final Widget child;
  const _SlotDragFeedback({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.03,
        child: Opacity(
          opacity: 0.92,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PopupRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PopupRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _CookAvatarStack extends ConsumerWidget {
  final List<String> cookIds;
  const _CookAvatarStack({required this.cookIds});

  static const double _radius = 11;
  static const double _overlap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatars =
        cookIds.map((id) => ref.watch(cookUserProvider(id)).value).toList();

    final width = _radius * 2 + (cookIds.length - 1) * (_radius * 2 - _overlap);

    return SizedBox(
      width: width,
      height: _radius * 2,
      child: Stack(
        children: List.generate(avatars.length, (i) {
          final user = avatars[i];
          return Positioned(
            left: i * (_radius * 2 - _overlap),
            child: CircleAvatar(
              radius: _radius,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  user?.imageUrl != null ? NetworkImage(user!.imageUrl!) : null,
              child: user?.imageUrl == null
                  ? Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
