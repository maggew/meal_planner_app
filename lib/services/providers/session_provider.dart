import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Synchroner State für die aktuelle Session
class SessionState {
  final String? userId;
  final String? groupId;
  final Group? group;
  final UserSettings? settings;
  final bool isLoading;

  const SessionState({
    this.userId,
    this.groupId,
    this.group,
    this.settings,
    this.isLoading = false,
  });

  SessionState copyWith({
    String? userId,
    String? groupId,
    Group? group,
    UserSettings? settings,
    bool? isLoading,
  }) {
    return SessionState(
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      group: group ?? this.group,
      settings: settings ?? this.settings,
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

      UserSettings settings = await storage.loadUserSettings();

      state = SessionState(
        userId: userId,
        groupId: groupId,
        group: group,
        settings: settings,
        isLoading: false,
      );

      print("Session geladen, aktive Gruppe: $groupId");
      print("active user: $userId");
    } catch (e) {
      state = SessionState(
        userId: userId,
        settings: UserSettings.defaultSettings,
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      print("1. start join group with groupId. $groupId");
      final groupRepo = ref.read(groupRepositoryProvider);
      final group = await groupRepo.getGroup(groupId);

      print("2. getGroup returned $group");
      if (group == null) {
        print("3a. group is null");
        throw Exception('Gruppe nicht gefunden');
      }

      final userId = state.userId;
      print("4. userId: $userId");
      await groupRepo.addMember(groupId, userId!);
      print("5. member hinzugefügt");

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

  Future<void> setActiveUserAfterRegistration(String userId) async {
    state = SessionState(
      userId: userId,
      groupId: null,
      group: null,
      settings: UserSettings.defaultSettings,
      isLoading: false,
    );
  }

  /// Session zurücksetzen (Logout)
  Future<void> clearSession() async {
    final storage = LocalStorageService();
    await storage.clearActiveGroup();
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(ref),
);
