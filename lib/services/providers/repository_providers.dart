import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/data/repositories/firebase_auth_repository.dart';
import 'package:meal_planner/data/repositories/firebase_storage_repository.dart';
import 'package:meal_planner/data/repositories/offline_first_meal_plan_repository.dart';
import 'package:meal_planner/data/repositories/offline_first_shopping_list_repository.dart';
import 'package:meal_planner/data/repositories/supabase_group_repository.dart';
import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_shopping_list_repository.dart';
import 'package:meal_planner/data/repositories/supabase_user_repository.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/data/datasources/recipe_remote_datasource.dart';
import 'package:meal_planner/data/datasources/supabase_recipe_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Firebase Instances
// final firestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return FirebaseStorageRepository(storage: ref.watch(storageProvider));
});

// Supabase Instances
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Supabase Instances
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final recipeRemoteDatasourceProvider = Provider<RecipeRemoteDatasource>((ref) {
  return SupabaseRecipeRemoteDatasource(
    ref.watch(supabaseProvider),
  );
});

// Recipe Repository - nutzt die GroupId aus dem State
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final session = ref.watch(sessionProvider);
  final groupId = session.groupId ?? '';

  final supabaseRepo = SupabaseRecipeRepository(
    supabase: ref.watch(supabaseProvider),
    storage: ref.watch(storageRepositoryProvider),
    remote: ref.watch(recipeRemoteDatasourceProvider),
    groupId: groupId,
  );

  return CachedRecipeRepository(
    remote: supabaseRepo,
    dao: ref.watch(recipeCacheDaoProvider),
    groupId: groupId,
    ref: ref,
  );
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return SupabaseGroupRepository(
    supabase: ref.watch(supabaseProvider),
  );
});

// User Repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return SupabaseUserRepository(
      supabase: ref.watch(supabaseProvider),
      storage: ref.watch(storageRepositoryProvider));
});

// Database
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final shoppingItemDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).shoppingItemDao;
});

final recipeCacheDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).recipeCacheDao;
});

final mealPlanDaoProvider = Provider((ref) {
  return ref.watch(appDatabaseProvider).mealPlanDao;
});

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final session = ref.watch(sessionProvider);
  final groupId = session.groupId ?? '';

  return OfflineFirstShoppingListRepository(
    groupId: groupId,
    ref: ref,
    dao: ref.watch(shoppingItemDaoProvider),
    remote: SupabaseShoppingListRepository(
      supabase: ref.watch(supabaseProvider),
      groupId: session.groupId ?? '',
    ),
  );
});

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final session = ref.watch(sessionProvider);
  return OfflineFirstMealPlanRepository(
    dao: ref.watch(mealPlanDaoProvider),
    supabase: ref.watch(supabaseProvider),
    groupId: session.groupId ?? '',
    ref: ref,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    userRepository: ref.watch(userRepositoryProvider),
    dio: ref.watch(dioProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
  );
});
