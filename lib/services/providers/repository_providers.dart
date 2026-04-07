import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_planner/core/security/pinned_http_client.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_planner/data/repositories/delete_account_repository_impl.dart';
import 'package:meal_planner/data/repositories/firebase_auth_repository.dart';
import 'package:meal_planner/data/repositories/firebase_storage_repository.dart';
import 'package:meal_planner/data/repositories/offline_first_meal_plan_repository.dart';
import 'package:meal_planner/data/repositories/offline_first_shopping_list_repository.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
import 'package:meal_planner/data/repositories/supabase_subscription_repository.dart';
import 'package:meal_planner/data/repositories/supabase_suggestion_usage_repository.dart';
import 'package:meal_planner/data/repositories/supabase_group_invitation_repository.dart';
import 'package:meal_planner/data/repositories/supabase_group_repository.dart';
import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_recipe_repository.dart';
import 'package:meal_planner/data/repositories/supabase_trash_repository.dart';
import 'package:meal_planner/data/repositories/supabase_user_repository.dart';
import 'package:meal_planner/domain/repositories/auth_repository.dart';
import 'package:meal_planner/domain/repositories/delete_account_repository.dart';
import 'package:meal_planner/domain/repositories/group_category_repository.dart';
import 'package:meal_planner/domain/repositories/group_invitation_repository.dart';
import 'package:meal_planner/domain/repositories/subscription_repository.dart';
import 'package:meal_planner/domain/repositories/suggestion_usage_repository.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/domain/repositories/trash_repository.dart';
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

// Pinned Dio — for requests to Supabase Edge Functions (e.g. Firebase auth bootstrap).
final pinnedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () => PinnedHttpClientFactory.createSupabaseHttpClient(),
  );
  return dio;
});

// Unpinned Dio — for recipe scraping (arbitrary external websites, can't pin).
final scrapingDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));
});

final recipeRemoteDatasourceProvider = Provider<RecipeRemoteDatasource>((ref) {
  return SupabaseRecipeRemoteDatasource(
    ref.watch(supabaseProvider),
  );
});

// Recipe Repository - nutzt die GroupId aus dem State
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';

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
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
  return OfflineFirstShoppingListRepository(
    dao: ref.watch(shoppingItemDaoProvider),
    groupId: groupId,
  );
});

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
  return OfflineFirstMealPlanRepository(
    dao: ref.watch(mealPlanDaoProvider),
    groupId: groupId,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    userRepository: ref.watch(userRepositoryProvider),
    dio: ref.watch(pinnedDioProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
  );
});

final groupInvitationRepositoryProvider =
    Provider<GroupInvitationRepository>((ref) {
  return SupabaseGroupInvitationRepository(
    supabase: ref.watch(supabaseProvider),
  );
});

final groupCategoryRepositoryProvider = Provider<GroupCategoryRepository>((ref) {
  return SupabaseGroupCategoryRepository(
    supabase: ref.watch(supabaseProvider),
  );
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SupabaseSubscriptionRepository(
    supabase: ref.watch(supabaseProvider),
  );
});

final suggestionUsageRepositoryProvider =
    Provider<SuggestionUsageRepository>((ref) {
  return SupabaseSuggestionUsageRepository(
    supabase: ref.watch(supabaseProvider),
  );
});

final deleteAccountRepositoryProvider =
    Provider<DeleteAccountRepository>((ref) {
  return DeleteAccountRepositoryImpl(
    db: ref.watch(appDatabaseProvider),
    auth: FirebaseAuth.instance,
    googleSignIn: ref.watch(googleSignInProvider),
    supabase: ref.watch(supabaseProvider),
  );
});

final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  final groupId = ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
  return SupabaseTrashRepository(
    remote: ref.watch(recipeRemoteDatasourceProvider),
    storage: ref.watch(storageRepositoryProvider),
    dao: ref.watch(recipeCacheDaoProvider),
    groupId: groupId,
  );
});
