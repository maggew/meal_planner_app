import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/data/model/group_model.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:mime/mime.dart';

class FirebaseGroupRepository implements GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final String Function() getCurrentGroupId;

  FirebaseGroupRepository({
    required this.firestore,
    required this.storage,
    required this.getCurrentGroupId,
  });
  CollectionReference get groupCollection =>
      firestore.collection(FirebaseConstants.groupsCollection);

  @override
  Future<void> createGroup(String groupID, String name, String imageUrl,
      String creatorUserID) async {
    try {
      await groupCollection.doc(groupID).set({
        'name': name,
        'iamgeUrl': imageUrl,
        'members': [creatorUserID],
        'groupID': groupID,
        'createdBy': creatorUserID,
      });
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Gruppe: $e');
    }
  }

  @override
  Future<void> updateGroupPic(String groupID, String url) async {
    try {
      await groupCollection.doc(groupID).update({'imageUrl': url});
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Gruppenbilds: $e');
    }
  }

  @override
  Future<Group> getCurrentGroup(String groupID) async {
    try {
      final snapshot = await groupCollection.doc(groupID).get();
      if (snapshot.data() != null) {
        return GroupModel.fromFirestore(
            snapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception(
            'Fehler beim Laden der Gruppe... snapshot.data() == null!');
      }
    } catch (e) {
      throw Exception('Fehler beim Laden der Gruppe: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getSingleGroupInfo(String groupID) async {
    try {
      final doc = await groupCollection.doc(groupID).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Fehler beim Laden der Gruppeninfo: $e');
    }
  }

  @override
  Future<void> updateGroupUsers(String groupID, String userID) async {
    try {
      await groupCollection.doc(groupID).update({
        'members': FieldValue.arrayUnion([userID]),
      });
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen des Users zur Gruppe: $e');
    }
  }

  @override
  Future<String> uploadGroupImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last.toLowerCase();
      final fileName = 'recipe_$timestamp.$extension';

      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final destination = '${FirebaseConstants.groupImagesPath}/$fileName';

      final ref = storage.ref().child(destination);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {'uploaded': DateTime.now().toIso8601String()},
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Upload fehlgeschlagen: ${e.message}');
    } catch (e) {
      throw Exception('Unerwarteter Fehler beim Upload: $e');
    }
  }

  //TODO: can be combined with deleteGroupImage to deleteImage
  @override
  Future<void> deleteRecipeImage(String imageUrl) async {
    try {
      await storage.refFromURL(imageUrl).delete();
    } catch (e) {
      throw Exception('Fehler beim Löschen des Bildes: $e');
    }
  }

  @override
  Future<List<Group>> getGroupsByIds(List<String> groupIds) async {
    try {
      if (groupIds.isEmpty) {
        return [];
      }

      final groupDocs = await Future.wait(
        groupIds.map((id) => firestore
            .collection(FirebaseConstants.groupsCollection)
            .doc(id)
            .get()),
      );

      return groupDocs
          .where((doc) => doc.exists)
          .map((doc) => GroupModel.fromFirestore(doc.data()!))
          .toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Gruppeninformationen: $e');
    }
  }
}
