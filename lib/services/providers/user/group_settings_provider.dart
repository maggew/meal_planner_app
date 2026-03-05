import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class GroupSettingsNotifier extends Notifier<GroupSettings> {
  @override
  GroupSettings build() {
    return ref.watch(
      sessionProvider.select((s) => s.group?.settings ?? GroupSettings.defaultSettings),
    );
  }

  Future<void> update(GroupSettings newSettings) async {
    final session = ref.read(sessionProvider);
    final groupId = session.groupId;
    final group = session.group;
    if (groupId == null || group == null) return;

    await ref.read(groupRepositoryProvider).updateSettings(groupId, newSettings);
    ref.read(sessionProvider.notifier).updateGroupLocally(
          group.copyWith(settings: newSettings),
        );
  }
}

final groupSettingsProvider =
    NotifierProvider<GroupSettingsNotifier, GroupSettings>(
  GroupSettingsNotifier.new,
);
