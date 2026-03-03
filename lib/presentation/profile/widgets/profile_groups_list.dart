import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_groups_provider.dart';

class ProfileGroupsList extends ConsumerWidget {
  const ProfileGroupsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupsProvider);
    final session = ref.watch(sessionProvider);
    final activeGroupId = session.groupId;
    final colorScheme = Theme.of(context).colorScheme;

    return userGroupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();

        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Meine Gruppen',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              ...groups.map((group) {
                final isActive = group.id == activeGroupId;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () async {
                      if (isActive) return;

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Gruppe wechseln'),
                          content: Text('Zu "${group.name}" wechseln?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Abbrechen'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Wechseln'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await ref
                            .read(sessionProvider.notifier)
                            .setActiveGroup(group.id);
                      }
                    },
                    child: AnimatedContainer(
                      duration: AppDimensions.animationDuration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary.withValues(alpha: 0.2)
                            : colorScheme.onSurface.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadius - 4,
                        ),
                        border: Border(
                          left: BorderSide(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.2),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 20,
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              group.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isActive
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                          if (isActive)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
}
