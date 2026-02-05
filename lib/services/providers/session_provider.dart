import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

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

      state = SessionState(
        userId: userId,
        groupId: groupId,
        isLoading: false,
      );

      print("Session geladen, aktive Gruppe: $groupId");
    } catch (e) {
      state = SessionState(userId: userId, isLoading: false);
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId) async {
    print("start joinGroup");
    final groupRepo = ref.read(groupRepositoryProvider);
    final group = await groupRepo.getGroup(groupId);
    print("groupId: $groupId");
    print(group.toString());

    if (group == null) {
      throw Exception('Gruppe nicht gefunden');
    }

    // In SharedPreferences speichern
    final storage = LocalStorageService();
    await storage.saveActiveGroup(groupId);

    // State aktualisieren
    state = state.copyWith(groupId: groupId, group: group);
  }

  Future<void> setActiveGroup(String groupId) async {
    final userId = state.userId;
    if (userId == null) return;

    final groupRepository = ref.read(groupRepositoryProvider);

    final group = await groupRepository.getGroup(groupId);

    state = state.copyWith(groupId: groupId, group: group);
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
