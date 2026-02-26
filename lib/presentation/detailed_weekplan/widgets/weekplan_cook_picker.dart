import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class WeekplanCookPicker extends ConsumerWidget {
  final String? currentCookId;
  final void Function(String? userId) onSelected;

  const WeekplanCookPicker({
    super.key,
    required this.currentCookId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groupId = ref.watch(sessionProvider).groupId ?? '';
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadius),
            ),
          ),
          child: Column(
            children: [
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
                child: Text('Koch auswählen', style: textTheme.titleSmall),
              ),
              Expanded(
                child: membersAsync.when(
                  data: (members) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    children: [
                      if (currentCookId != null)
                        ListTile(
                          leading: const Icon(Icons.person_off_outlined),
                          title: Text('Koch entfernen',
                              style: textTheme.bodyMedium),
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected(null);
                          },
                        ),
                      const Divider(height: 1),
                      ...members.map((user) => _MemberTile(
                            user: user,
                            isSelected: user.id == currentCookId,
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelected(user.id);
                            },
                          )),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
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
