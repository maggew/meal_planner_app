import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage storage;

  FirebaseStorageRepository({required this.storage});

  @override
  Future<String> uploadImage(File file, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = storage.ref().child('$folder/$fileName');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print("error in storage...");
      // Image existiert nicht mehr
    }
  }
}
