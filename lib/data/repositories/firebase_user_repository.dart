// lib/data/repositories/firebase_user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_planner/data/model/user_model.dart';
import 'package:meal_planner/domain/entities/user.dart';
import 'package:meal_planner/domain/repositories/user_repository.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore firestore;

  FirebaseUserRepository({required this.firestore});

  @override
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final user = User(
        uid: uid,
        name: name,
        email: email,
        groups: [],
        currentGroup: null,
      );

      final model = UserModel.fromEntity(user);

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set(model.toFirestore());
    } catch (e) {
      throw Exception('Fehler beim Erstellen des Users: $e');
    }
  }

  @override
  Future<User?> getUserById(String uid) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Fehler beim Laden des Users: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final model = UserModel.fromEntity(user);

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(model.toFirestore());
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Users: $e');
    }
  }

  @override
  Future<void> addUserToGroup(String uid, String groupId) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'groups': FieldValue.arrayUnion([groupId]),
      });

      // Wenn erste Gruppe, setze als aktiv
      final user = await getUserById(uid);
      if (user != null && !user.hasActiveGroup) {
        await setActiveGroup(uid, groupId);
      }
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen zur Gruppe: $e');
    }
  }

  @override
  Future<void> removeUserFromGroup(String uid, String groupId) async {
    try {
      final user = await getUserById(uid);
      if (user == null) return;

      // Entferne Gruppe
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      // Wenn aktive Gruppe entfernt wurde
      if (user.currentGroup == groupId) {
        final remainingGroups = user.groups.where((g) => g != groupId).toList();
        if (remainingGroups.isNotEmpty) {
          await setActiveGroup(uid, remainingGroups.first);
        } else {
          await setActiveGroup(uid, '');
        }
      }
    } catch (e) {
      throw Exception('Fehler beim Entfernen aus der Gruppe: $e');
    }
  }

  @override
  Future<void> setActiveGroup(String uid, String groupId) async {
    try {
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        'current_group': groupId,
      });
    } catch (e) {
      throw Exception('Fehler beim Setzen der aktiven Gruppe: $e');
    }
  }

  @override
  Future<String?> getCurrentGroupId(String uid) async {
    try {
      final user = await getUserById(uid);
      return user?.currentGroup;
    } catch (e) {
      throw Exception('Fehler beim Laden der GroupId: $e');
    }
  }
}
