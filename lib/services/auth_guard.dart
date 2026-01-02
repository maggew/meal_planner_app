import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
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
    final userId = authRepo.getCurrentUserId();

    if (userId == null || userId.isEmpty) {
      router.replace(const LoginRoute());
      return;
    }

    final currentSession = ref.read(sessionProvider);
    if (currentSession.userId != userId || currentSession.group == null) {
      await ref.read(sessionProvider.notifier).loadSession(userId);
    }

    final session = ref.read(sessionProvider);

    if (session.groupId == null || session.groupId!.isEmpty) {
      router.replace(const GroupsRoute());
      return;
    }

    resolver.next(true);
  }
}
