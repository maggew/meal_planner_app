import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late ProviderContainer container;
  late MockStorageRepository mockStorage;

  const fakeUrl = 'https://firebase.storage/recipe/123.jpg';

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockStorage = MockStorageRepository();
    container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorage),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ImageManager.cleanupPendingPhoto', () {
    test('deletes uploaded image when form is cancelled after photo selection',
        () async {
      // arrange
      when(() => mockStorage.uploadImage(any(), any()))
          .thenAnswer((_) async => fakeUrl);
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act: user picks a photo → upload starts immediately
      container.read(imageManagerProvider.notifier).setPhoto(File('test.jpg'));
      // act: user cancels the form → dispose calls cleanupPendingPhoto
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert: uploaded image was deleted from Firebase Storage
      verify(() => mockStorage.deleteImage(fakeUrl)).called(1);
    });

    test(
        'does not delete image when clearPhoto was called before cleanup (save scenario)',
        () async {
      // arrange
      when(() => mockStorage.uploadImage(any(), any()))
          .thenAnswer((_) async => fakeUrl);
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act: user picks photo, saves recipe → _resetForm calls clearPhoto
      container.read(imageManagerProvider.notifier).setPhoto(File('test.jpg'));
      container.read(imageManagerProvider.notifier).clearPhoto();
      // act: page disposes after navigation
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert: nothing deleted — image is already committed to the recipe
      verifyNever(() => mockStorage.deleteImage(any()));
    });

    test('does nothing when no photo was ever selected', () async {
      // arrange
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert
      verifyNever(() => mockStorage.deleteImage(any()));
    });

    test('does not call deleteImage when the upload failed (URL is null)',
        () async {
      // arrange: upload throws → _startUpload catches and returns null
      when(() => mockStorage.uploadImage(any(), any()))
          .thenThrow(Exception('network error'));
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act
      container.read(imageManagerProvider.notifier).setPhoto(File('test.jpg'));
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert: no URL to delete
      verifyNever(() => mockStorage.deleteImage(any()));
    });

    test('clears photo state after cleanup', () async {
      // arrange
      when(() => mockStorage.uploadImage(any(), any()))
          .thenAnswer((_) async => fakeUrl);
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act
      container.read(imageManagerProvider.notifier).setPhoto(File('test.jpg'));
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert: local state is cleared
      final images = container.read(imageManagerProvider);
      expect(images.photo, isNull);
      expect(images.pendingPhotoUpload, isNull);
    });

    test('second cleanup call after first is a no-op (not double-delete)',
        () async {
      // arrange
      when(() => mockStorage.uploadImage(any(), any()))
          .thenAnswer((_) async => fakeUrl);
      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});

      // act
      container.read(imageManagerProvider.notifier).setPhoto(File('test.jpg'));
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();
      await container.read(imageManagerProvider.notifier).cleanupPendingPhoto();

      // assert: deleted exactly once
      verify(() => mockStorage.deleteImage(fakeUrl)).called(1);
    });
  });
}
