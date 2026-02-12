import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/user_profile.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(sessionProvider).userId;
  if (userId == null) return null;
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserProfileById(userId);
});
