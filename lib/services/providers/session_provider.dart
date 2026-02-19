import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/services/providers/realtime_auth_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Synchroner State für die aktuelle Session
class SessionState {
  final String? userId;
  final String? groupId;
  final Group? group;
  final bool isLoading;

  const SessionState({
    this.userId,
    this.groupId,
    this.group,
    this.isLoading = false,
  });

  SessionState copyWith({
    String? userId,
    String? groupId,
    Group? group,
    bool? isLoading,
  }) {
    return SessionState(
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      group: group ?? this.group,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Session Controller
class SessionController extends StateNotifier<SessionState> {
  SessionController(this.ref) : super(const SessionState());

  final Ref ref;

  /// Lädt die komplette Session (userId + groupId + Group-Daten)
  Future<void> loadSession(String userId) async {
    state = state.copyWith(isLoading: true, userId: userId);

    try {
      final storage = LocalStorageService();
      final groupId = await storage.loadActiveGroup();

      Group? group;
      if (groupId != null) {
        final groupRepo = ref.read(groupRepositoryProvider);
        group = await groupRepo.getGroup(groupId);
      }

      await ref.read(realtimeAuthServiceProvider).initialize();

      state = SessionState(
        userId: userId,
        groupId: groupId,
        group: group,
        isLoading: false,
      );
    } catch (e) {
      state = SessionState(
        userId: userId,
        isLoading: false,
      );
      rethrow;
    }
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

      state = state.copyWith(groupId: groupId, group: group);
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
    final storage = LocalStorageService();
    await storage.saveActiveGroup(groupId);

    state = state.copyWith(groupId: groupId, group: group);
  }

  Future<void> reloadActiveGroup() async {
    final groupId = state.groupId;
    if (groupId == null) return;

    final groupRepo = ref.read(groupRepositoryProvider);
    final group = await groupRepo.getGroup(groupId);

    state = state.copyWith(group: group);
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
    final storage = LocalStorageService();
    await storage.clearActiveGroup();
    ref.read(realtimeAuthServiceProvider).dispose();
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(ref),
);
