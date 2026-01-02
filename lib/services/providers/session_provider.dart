import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
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
      final userRepo = ref.read(userRepositoryProvider);
      final groupId = await userRepo.getCurrentGroupId(userId);

      if (groupId == null || groupId.isEmpty) {
        state = SessionState(userId: userId, isLoading: false);
        return;
      }

      final groupRepo = ref.read(groupRepositoryProvider);
      final group = await groupRepo.getCurrentGroup(groupId);

      state = SessionState(
        userId: userId,
        groupId: groupId,
        group: group,
        isLoading: false,
      );
    } catch (e) {
      state = SessionState(userId: userId, isLoading: false);
      rethrow;
    }
  }

  /// Session zurücksetzen (Logout)
  void clearSession() {
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(ref),
);
