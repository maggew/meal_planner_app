import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_groups_provider.dart';

Future<void> _confirmLeaveGroup(
  BuildContext context,
  WidgetRef ref,
  String groupId,
  String groupName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Gruppe verlassen'),
      content: Text('Möchtest du "$groupName" wirklich verlassen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          child: const Text('Verlassen'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  try {
    final session = ref.read(sessionProvider);
    final groupRepo = ref.read(groupRepositoryProvider);
    await groupRepo.removeMember(groupId, session.userId!);

    // Clear active group (keeps userId intact)
    await ref.read(sessionProvider.notifier).leaveActiveGroup();

    // Refresh groups list
    ref.invalidate(userGroupsProvider);

    if (context.mounted) {
      context.router.replaceAll([const GroupsRoute()]);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }
}

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
              ...groups.map<Widget>((group) {
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.router.push(const JoinGroupRoute()),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Beitreten'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: activeGroupId == null
                          ? null
                          : () => _confirmLeaveGroup(
                                context,
                                ref,
                                activeGroupId,
                                groups
                                    .firstWhere((g) => g.id == activeGroupId)
                                    .name,
                              ),
                      icon: Icon(
                        Icons.logout,
                        size: 18,
                        color: activeGroupId != null
                            ? colorScheme.error
                            : null,
                      ),
                      label: Text(
                        'Verlassen',
                        style: activeGroupId != null
                            ? TextStyle(color: colorScheme.error)
                            : null,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: activeGroupId != null
                            ? BorderSide(
                                color: colorScheme.error.withValues(alpha: 0.5))
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
}
