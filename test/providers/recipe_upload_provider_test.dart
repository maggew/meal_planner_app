import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/services/providers/recipe/recipe_upload_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late ProviderContainer container;
  late MockRecipeRepository mockRepo;

  final testRecipe = Recipe(
    name: 'Test Recipe',
    categories: ['Test'],
    portions: 4,
    ingredientSections: [],
    instructions: 'Test instructions',
  );

  setUp(() {
    mockRepo = MockRecipeRepository();

    container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRepo),
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
  });
}
