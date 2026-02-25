import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class AuthGuard extends AutoRouteGuard {
  final Ref ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final authRepo = ref.read(authRepositoryProvider);
    final firebaseUid = authRepo.getCurrentUserId();

    if (firebaseUid == null || firebaseUid.isEmpty) {
      router.replace(const LoginRoute());
      return;
    }

    final storage = LocalStorageService();

    // Supabase-UserId holen: erst online versuchen, dann Cache
    String? supabaseUserId;
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final user = await userRepo.getUserByFirebaseUid(firebaseUid);
      if (user != null) {
        supabaseUserId = user.id;
        await storage.saveSupabaseUserId(user.id);
      }
    } catch (_) {
      // Netzwerkfehler: gecachte ID verwenden
    }
    // Fallback: wenn getUserByFirebaseUid null zurückgab (Fehler intern schluckt),
    // aus Cache laden
    supabaseUserId ??= await storage.loadSupabaseUserId();

    if (supabaseUserId == null) {
      router.replace(const LoginRoute());
      return;
    }

    final currentSession = ref.read(sessionProvider);
    if (currentSession.userId != supabaseUserId ||
        currentSession.group == null) {
      await ref.read(sessionProvider.notifier).loadSession(supabaseUserId);
    }

    final session = ref.read(sessionProvider);

    if (session.groupId == null || session.groupId!.isEmpty) {
      // Offline: keine Gruppenabfrage möglich → direkt zur Gruppenauswahl
      try {
        final groupRepo = ref.read(groupRepositoryProvider);
        final groups = await groupRepo.getUserGroups(supabaseUserId);
        if (groups.isEmpty) {
          router.replace(const GroupOnboardingRoute());
        } else {
          router.replace(GroupsRoute());
        }
      } catch (_) {
        router.replace(const GroupOnboardingRoute());
      }
      return;
    }

    resolver.next(true);
  }
}
