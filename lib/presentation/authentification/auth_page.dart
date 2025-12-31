import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

@RoutePage()
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<void>(
      future: _checkAuthAndNavigate(context, ref),
      builder: (context, snapshot) {
        return AppBackground(
          scaffoldBody: Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        );
      },
    );
  }

  Future<void> _checkAuthAndNavigate(
      BuildContext context, WidgetRef ref) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final uid = authRepo.getCurrentUserId();

      if (uid == null || uid.isEmpty) {
        AutoRouter.of(context).replace(const LoginRoute());
        return;
      }

      final userRepo = ref.read(userRepositoryProvider);
      final groupId = await userRepo.getCurrentGroupId(uid);

      if (groupId == null || groupId.isEmpty) {
        AutoRouter.of(context).replace(const GroupsRoute());
      } else {
        ref.read(currentGroupIdStateProvider.notifier).state = groupId;
        AutoRouter.of(context).replace(const CookbookRoute());
      }
    } catch (e) {
      print('Auth Check Fehler: $e');
      AutoRouter.of(context).replace(const LoginRoute());
    }
  }
}

