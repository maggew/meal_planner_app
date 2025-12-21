import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ImagePathNotifier extends AsyncNotifier<String?> {
  final _imagePicker = ImagePicker();

  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> pickFromGallery() async {
    state = const AsyncLoading();
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

      if (result == null) {
        state = const AsyncData(null);
        return;
      }

      state = AsyncData(result.files.single.path);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> pickFromCamera() async {
    state = const AsyncLoading();
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) {
        state = const AsyncData(null);
        return;
      }

      state = AsyncData(image.path);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final imagePathProvider = AsyncNotifierProvider<ImagePathNotifier, String?>(
  ImagePathNotifier.new,
);
