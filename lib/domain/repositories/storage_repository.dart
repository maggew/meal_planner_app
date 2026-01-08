import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadImage(File file, String folder);
  Future<void> deleteImage(String imageUrl);
}
