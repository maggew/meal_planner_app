import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/group_invitation.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';
import 'package:meal_planner/services/providers/groups/group_invitation_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/active_group_members_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    final session = ref.watch(sessionProvider);
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
          if (session.isAdmin) _InviteSection(groupName: group.name),
        ],
      ),
    );
  }
}

class _InviteSection extends ConsumerStatefulWidget {
  final String groupName;

  const _InviteSection({required this.groupName});

  @override
  ConsumerState<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends ConsumerState<_InviteSection> {
  bool _isCreating = false;

  Future<void> _createInvitation() async {
    setState(() => _isCreating = true);
    try {
      final session = ref.read(sessionProvider);
      final repo = ref.read(groupInvitationRepositoryProvider);
      await repo.createInvitation(
        groupId: session.groupId!,
        createdBy: session.userId!,
      );
      ref.invalidate(activeGroupInvitationProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _shareCode(GroupInvitation invitation) {
    final d = invitation.expiresAt;
    final expiryDate = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    Share.share(
      'Tritt unserer Gruppe "${widget.groupName}" bei! '
      'Gib diesen Code in der Meal Planner App ein: '
      '${invitation.code} (gültig bis $expiryDate)',
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code kopiert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invitationAsync = ref.watch(activeGroupInvitationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          'Einladung',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 8),
        invitationAsync.when(
          loading: () => const SizedBox(
            height: 36,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => _buildCreateButton(colorScheme),
          data: (invitation) {
            if (invitation == null || invitation.isExpired) {
              return _buildCreateButton(colorScheme);
            }
            return _buildActiveInvitation(invitation, colorScheme);
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isCreating ? null : _createInvitation,
        icon: _isCreating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.link, size: 18),
        label: const Text('Einladungscode erstellen'),
      ),
    );
  }

  Widget _buildActiveInvitation(
    GroupInvitation invitation,
    ColorScheme colorScheme,
  ) {
    final d = invitation.expiresAt;
    final expiryDate = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      invitation.code,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gültig bis $expiryDate  ·  ${invitation.useCount}× genutzt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Code kopieren',
                onPressed: () => _copyCode(invitation.code),
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                tooltip: 'Teilen',
                onPressed: () => _shareCode(invitation),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _isCreating ? null : _createInvitation,
            icon: _isCreating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: const Text('Neuen Code erstellen'),
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
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
