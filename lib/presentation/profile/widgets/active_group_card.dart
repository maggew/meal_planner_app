import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/services/providers/user/active_group_members_provider.dart';

class ActiveGroupCard extends ConsumerWidget {
  const ActiveGroupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(activeGroupProvider);

    return groupAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
      data: (group) {
        if (group == null) return const SizedBox.shrink();
        return _ActiveGroupContent(group: group);
      },
    );
  }
}

class _ActiveGroupContent extends ConsumerWidget {
  final Group group;

  const _ActiveGroupContent({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(activeGroupMembersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Aktive Gruppe',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: group.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          group.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      )
                    : const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.group_rounded, size: 28),
                      ),
              ),
              const SizedBox(width: 14),
              Text(
                group.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          membersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (members) {
              if (members.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    'Mitglieder',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: members
                        .map((member) => _MemberChip(
                              name: member.name,
                              imageUrl: member.imageUrl,
                            ))
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _MemberChip({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return ColoredBox(
                        color: colorScheme.primaryContainer,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
