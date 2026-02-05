import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final userRepo = ref.read(userRepositoryProvider);
    final user = await userRepo.getUserByFirebaseUid(firebaseUid);

    if (user == null) {
      router.replace(const LoginRoute());
      return;
    }

    final currentSession = ref.read(sessionProvider);
    if (currentSession.userId != user.id || currentSession.group == null) {
      await ref.read(sessionProvider.notifier).loadSession(user.id);
    }

    final session = ref.read(sessionProvider);

    if (session.groupId == null || session.groupId!.isEmpty) {
      final groupRepo = ref.read(groupRepositoryProvider);
      final groups = await groupRepo.getUserGroups(user.id);

      if (groups.isEmpty) {
        router.replace(const GroupOnboardingRoute());
      } else {
        router.replace(GroupsRoute());
      }
      return;
    }
    resolver.next(true);
  }
}
