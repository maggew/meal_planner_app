import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/group_role.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'session_provider.g.dart';

/// Synchroner State für die aktuelle Session
class SessionState {
  final String? userId;
  final String? groupId;
  final Group? group;
  final GroupRole? role;
  final bool isLoading;

  const SessionState({
    this.userId,
    this.groupId,
    this.group,
    this.role,
    this.isLoading = false,
  });

  bool get isAdmin => role == GroupRole.admin;

  SessionState copyWith({
    String? userId,
    String? groupId,
    Group? group,
    GroupRole? role,
    bool? isLoading,
  }) {
    return SessionState(
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      group: group ?? this.group,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  @override
  SessionState build() => const SessionState();

  /// Lädt die komplette Session (userId + groupId + Group-Daten + Rolle)
  Future<void> loadSession(String userId) async {
    state = state.copyWith(isLoading: true, userId: userId);

    final storage = LocalStorageService();
    final groupId = await storage.loadActiveGroup();

    Group? group;
    GroupRole? role;
    if (groupId != null) {
      try {
        final groupRepo = ref.read(groupRepositoryProvider);
        group = await groupRepo.getGroup(groupId);
        role = await groupRepo.getMemberRole(groupId, userId);
        if (group != null) {
          await storage.saveGroup(group);
        }
      } catch (_) {
        // Offline: gecachte Gruppe laden
        group = await storage.loadGroup(groupId);
      }
    }

    state = SessionState(
      userId: userId,
      groupId: groupId,
      group: group,
      role: role,
      isLoading: false,
    );
  }

  Future<void> joinGroup(String groupId) async {
    try {
      final groupRepo = ref.read(groupRepositoryProvider);
      final group = await groupRepo.getGroup(groupId);

      if (group == null) {
        throw Exception('Gruppe nicht gefunden');
      }

      final userId = state.userId;
      await groupRepo.addMember(groupId, userId!);

      final storage = LocalStorageService();
      await storage.saveActiveGroup(groupId);

      state = state.copyWith(groupId: groupId, group: group, role: GroupRole.member);
    } on GroupNotFoundException {
      rethrow;
    } on PostgrestException catch (e) {
      throw Exception('Datenbankfehler: ${e.message}');
    } catch (e) {
      throw Exception('Fehler beim Beitreten: $e');
    }
  }

  Future<void> setActiveGroup(String groupId) async {
    final userId = state.userId;
    if (userId == null) return;

    final groupRepository = ref.read(groupRepositoryProvider);

    final group = await groupRepository.getGroup(groupId);
    final role = await groupRepository.getMemberRole(groupId, userId);
    final storage = LocalStorageService();
    await storage.saveActiveGroup(groupId);

    state = state.copyWith(groupId: groupId, group: group, role: role);
  }

  Future<void> reloadActiveGroup() async {
    final groupId = state.groupId;
    if (groupId == null) return;

    final groupRepo = ref.read(groupRepositoryProvider);
    final group = await groupRepo.getGroup(groupId);

    state = state.copyWith(group: group);
  }

  void updateGroupLocally(Group updated) {
    state = state.copyWith(group: updated);
  }

  void setActiveUserAfterRegistration(String userId) {
    state = SessionState(
      userId: userId,
      groupId: null,
      group: null,
      isLoading: false,
    );
  }

  Future<void> changeSettings(UserSettings settings) async {
    final storage = LocalStorageService();
    await storage.saveUserSettings(settings);
  }

  /// Session zurücksetzen (Logout)
  Future<void> clearSession() async {
    final groupId = state.groupId;
    final storage = LocalStorageService();
    await storage.clearActiveGroup();
    if (groupId != null) await storage.clearGroup(groupId);
    state = const SessionState();
  }
}

