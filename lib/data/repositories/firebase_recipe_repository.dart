// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:meal_planner/core/constants/firebase_constants.dart';
// import 'package:meal_planner/data/model/recipe_model.dart';
// import 'package:meal_planner/domain/entities/recipe.dart';
// import 'package:meal_planner/domain/repositories/recipe_repository.dart';
//
// class FirebaseRecipeRepository implements RecipeRepository {
//   final FirebaseFirestore firestore;
//   final FirebaseStorage storage;
//   final String Function() getCurrentGroupId;
//
//   FirebaseRecipeRepository({
//     required this.firestore,
//     required this.storage,
//     required this.getCurrentGroupId,
//   });
//
//   @override
//   Future<String> saveRecipe(Recipe recipe, File? image) async {
//     try {
//       final groupId = getCurrentGroupId();
//       if (groupId.isEmpty) {
//         throw Exception('Keine aktive Gruppe');
//       }
//
//       // Entity → Model → JSON
//       final model = RecipeModel.fromEntity(recipe);
//
//       // final docRef = await firestore
//       //     .collection(FirebaseConstants.recipesCollection)
//       //     .doc(groupId)
//       //     .collection(recipe.category)
//       //     .add(model.toFirestore());
//
//       final docRef = await firestore
//           .collection(FirebaseConstants.groupsCollection)
//           .doc(groupId)
//           .collection(FirebaseConstants.recipesInGroups)
//           .add(model.toFirestore());
//
//       return docRef.id;
//     } catch (e) {
//       throw Exception('Fehler beim Speichern des Rezepts: $e');
//     }
//   }
//
//   @override
//   Future<List<Recipe>> getRecipesByCategory(String category) async {
//     try {
//       final groupId = getCurrentGroupId();
//
//       final querySnapshot = await firestore
//           .collection(FirebaseConstants.groupsCollection)
//           .doc(groupId)
//           .collection(FirebaseConstants.recipesInGroups)
//           .where(FirebaseConstants.recipeCategory, isEqualTo: category)
//           .get();
//
//       if (groupId.isEmpty) {
//         return [];
//       }
//
//       final recipes = querySnapshot.docs.map((doc) {
//         final data = doc.data();
//
//         // Standard-Bild wenn keins vorhanden
//         if (data[FirebaseConstants.recipeImage] == null ||
//             data[FirebaseConstants.recipeImage] == '') {
//           data[FirebaseConstants.recipeImage] =
//               'assets/images/default_pic_2.jpg';
//         }
//
//         // Firebase → Model → Entity
//         return RecipeModel.fromFirestore(data, doc.id).toEntity();
//       }).toList();
//
//       return recipes;
//     } catch (e) {
//       throw Exception('Fehler beim Laden der Rezepte: $e');
//     }
//   }
//
//   @override
//   Future<Recipe?> getRecipeById(String recipeId, String category) async {
//     try {
//       final groupId = getCurrentGroupId();
//       if (groupId.isEmpty) return null;
//
//       final doc = await firestore
//           .collection(FirebaseConstants.recipesCollection)
//           .doc(groupId)
//           .collection(category)
//           .doc(recipeId)
//           .get();
//
//       if (!doc.exists) return null;
//
//       final data = doc.data()!;
//       if (data[FirebaseConstants.recipeImage] == null ||
//           data[FirebaseConstants.recipeImage] == '') {
//         data[FirebaseConstants.recipeImage] = 'assets/images/default_pic_2.jpg';
//       }
//
//       return RecipeModel.fromFirestore(data, doc.id).toEntity();
//     } catch (e) {
//       throw Exception('Fehler beim Laden des Rezepts: $e');
//     }
//   }
//
//   @override
//   Future<void> updateRecipe(
//       String recipeId, String category, Recipe recipe) async {
//     try {
//       final groupId = getCurrentGroupId();
//       if (groupId.isEmpty) {
//         throw Exception('Keine aktive Gruppe');
//       }
//
//       final model = RecipeModel.fromEntity(recipe);
//       await firestore
//           .collection(FirebaseConstants.recipesCollection)
//           .doc(groupId)
//           .collection(category)
//           .doc(recipeId)
//           .update(model.toFirestore());
//     } catch (e) {
//       throw Exception('Fehler beim Aktualisieren des Rezepts: $e');
//     }
//   }
//
//   @override
//   Future<void> deleteRecipe(String recipeId, String category) async {
//     try {
//       final groupId = getCurrentGroupId();
//       if (groupId.isEmpty) {
//         throw Exception('Keine aktive Gruppe');
//       }
//
//       // Dann das Rezept löschen
//       await firestore
//           .collection(FirebaseConstants.recipesCollection)
//           .doc(groupId)
//           .collection(category)
//           .doc(recipeId)
//           .delete();
//     } catch (e) {
//       throw Exception('Fehler beim Löschen des Rezepts: $e');
//     }
//   }
// }
