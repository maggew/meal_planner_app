import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/router/router.dart';
import 'package:meal_planner/services/auth_guard.dart';

final appRouterProvider = Provider<AppRouter>((ref) {
  final authGuard = AuthGuard(ref);
  return AppRouter(authGuard);
});
