import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/domain/repositories/storage_repository.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/recipe/recipe_upload_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late ProviderContainer container;
  late MockRecipeRepository mockRepo;
  late MockStorageRepository mockStorage;

  final testRecipe = Recipe(
    name: 'Test Recipe',
    categories: ['Test'],
    portions: 4,
    ingredientSections: [],
    instructions: 'Test instructions',
  );

  setUp(() {
    mockRepo = MockRecipeRepository();
    mockStorage = MockStorageRepository();

    container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRepo),
        storageRepositoryProvider.overrideWithValue(mockStorage),
        sessionProvider.overrideWithValue(
          const SessionState(userId: 'user-1'),
        ),
      ],
    );

    registerFallbackValue(testRecipe);
    registerFallbackValue(File('dummy'));
  });

  tearDown(() {
    container.dispose();
  });

  group('RecipeUpload Provider', () {
    test('initial state is AsyncData', () {
      final state = container.read(recipeUploadProvider);

      expect(state, isA<AsyncData>());
    });

    test('createRecipe calls saveRecipe with correct parameters', () async {
      // arrange
      when(() => mockRepo.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'test-recipe-id');

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .createRecipe(testRecipe, null);

      // assert
      verify(() => mockRepo.saveRecipe(testRecipe, null, 'user-1')).called(1);
    });

    test('createRecipe transitions to loading then back to data', () async {
      // arrange
      final states = <AsyncValue<void>>[];

      container.listen(
        recipeUploadProvider,
        (previous, next) {
          states.add(next);
        },
      );

      when(() => mockRepo.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'test-recipe-id');

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .createRecipe(testRecipe, null);

      // assert
      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0].isLoading, true);
      expect(states.last.hasValue, true);
      expect(states.last.hasError, false);
    });

    test('createRecipe sets AsyncError on failure', () async {
      // arrange
      when(() => mockRepo.saveRecipe(any(), any(), any()))
          .thenThrow(Exception('Upload failed'));

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .createRecipe(testRecipe, null);

      // assert
      final state = container.read(recipeUploadProvider);
      expect(state, isA<AsyncError>());
      expect(state.hasError, true);
    });

    test('createRecipe passes image to repository', () async {
      // arrange
      final file = File('test_image.png');
      when(() => mockRepo.saveRecipe(any(), any(), any()))
          .thenAnswer((_) async => 'test-recipe-id');

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .createRecipe(testRecipe, file);

      // assert
      verify(() => mockRepo.saveRecipe(testRecipe, file, 'user-1')).called(1);
    });

    test('updateRecipe calls repository with correct parameters', () async {
      // arrange
      final recipe = testRecipe.copyWith(id: 'r1');
      when(() => mockRepo.updateRecipe(any(), any()))
          .thenAnswer((_) async {});

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, null);

      // assert
      verify(() => mockRepo.updateRecipe(recipe, null)).called(1);
    });

    test('updateRecipe sets AsyncError on failure', () async {
      // arrange
      final recipe = testRecipe.copyWith(id: 'r1');
      when(() => mockRepo.updateRecipe(any(), any()))
          .thenThrow(Exception('Update failed'));

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, null);

      // assert
      final state = container.read(recipeUploadProvider);
      expect(state, isA<AsyncError>());
    });

    test(
        'updateRecipe uses pre-uploaded URL and skips re-upload when pendingPhotoUpload is set',
        () async {
      // arrange: pre-upload already completed
      const preUploadedUrl = 'https://firebase.storage/recipe/pre.jpg';
      final recipe = testRecipe.copyWith(id: 'r1');
      final file = File('new_photo.jpg');

      container.read(imageManagerProvider.notifier).state = CustomImages(
        photo: file,
        pendingPhotoUpload: Future.value(preUploadedUrl),
      );

      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});
      when(() => mockRepo.updateRecipe(any(), any())).thenAnswer((_) async {});

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, file);

      // assert: no re-upload, repo called with null image and pre-uploaded URL
      final captured =
          verify(() => mockRepo.updateRecipe(captureAny(), captureAny()))
              .captured;
      expect((captured[0] as Recipe).imageUrl, preUploadedUrl);
      expect(captured[1], isNull);
      verifyNever(() => mockStorage.uploadImage(any(), any()));
    });

    test(
        'updateRecipe deletes old image when using pre-uploaded URL',
        () async {
      // arrange
      const oldUrl = 'https://firebase.storage/recipe/old.jpg';
      const preUploadedUrl = 'https://firebase.storage/recipe/pre.jpg';
      final recipe = testRecipe.copyWith(id: 'r1', imageUrl: oldUrl);
      final file = File('new_photo.jpg');

      container.read(imageManagerProvider.notifier).state = CustomImages(
        photo: file,
        pendingPhotoUpload: Future.value(preUploadedUrl),
      );

      when(() => mockStorage.deleteImage(any())).thenAnswer((_) async {});
      when(() => mockRepo.updateRecipe(any(), any())).thenAnswer((_) async {});

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, file);

      // assert: old image deleted before using pre-uploaded URL
      verify(() => mockStorage.deleteImage(oldUrl)).called(1);
    });

    test('updateRecipe uploads file normally when no pendingPhotoUpload',
        () async {
      // arrange: no pre-upload in imageManagerProvider
      final recipe = testRecipe.copyWith(id: 'r1');
      final file = File('new_photo.jpg');

      when(() => mockRepo.updateRecipe(any(), any())).thenAnswer((_) async {});

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, file);

      // assert: file passed through to repo as-is
      verify(() => mockRepo.updateRecipe(recipe, file)).called(1);
      verifyNever(() => mockStorage.deleteImage(any()));
    });

    test(
        'updateRecipe falls back to file upload when pendingPhotoUpload resolves to null',
        () async {
      // arrange: pre-upload was attempted but failed → Future resolves to null
      final recipe = testRecipe.copyWith(id: 'r1');
      final file = File('new_photo.jpg');

      container.read(imageManagerProvider.notifier).state = CustomImages(
        photo: file,
        pendingPhotoUpload: Future.value(null),
      );

      when(() => mockRepo.updateRecipe(any(), any())).thenAnswer((_) async {});

      // act
      await container
          .read(recipeUploadProvider.notifier)
          .updateRecipe(recipe, file);

      // assert: falls back to passing the file to the repo for upload
      final captured =
          verify(() => mockRepo.updateRecipe(captureAny(), captureAny()))
              .captured;
      expect(captured[1], file);
      verifyNever(() => mockStorage.deleteImage(any()));
    });
  });
}
