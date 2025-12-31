import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_planner/data/repositories/firebase_fridge_repository.dart';
import 'package:meal_planner/data/repositories/firebase_group_repository.dart';
import 'package:meal_planner/domain/repositories/fridge_repository.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/data/repositories/firebase_recipe_repository.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

// Firebase Instances
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Recipe Repository - nutzt die GroupId aus dem State
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final groupId = ref.watch(currentGroupIdStateProvider);

  return FirebaseRecipeRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
    getCurrentGroupId: () => groupId,
  );
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final groupId = ref.watch(currentGroupIdStateProvider);

  return FirebaseGroupRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
    getCurrentGroupId: () => groupId,
  );
});

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  final groupId = ref.watch(currentGroupIdStateProvider);

  return FirebaseFridgeRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
    getCurrentGroupId: () => groupId,
  );
});
