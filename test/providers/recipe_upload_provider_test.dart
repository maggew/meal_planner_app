import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/services/providers/recipe/recipe_upload_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Mock für Repository
@GenerateMocks([RecipeRepository])
import 'recipe_upload_provider_test.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockRecipeRepository mockRepo;

  setUp(() {
    mockRepo = MockRecipeRepository();

    container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('RecipeUpload Provider', () {
    test('initial state should be AsyncData', () {
      final state = container.read(recipeUploadProvider);

      expect(state, isA<AsyncData>());
    });

    test('should transition to loading state during upload', () async {
      // Arrange
      final recipe = Recipe(
        name: 'Test Recipe',
        categories: ['Test'],
        portions: 4,
        ingredients: [
          Ingredient(name: 'Zutat', amount: 100, unit: Unit.GRAMM),
        ],
        instructions: 'Test instructions',
      );

      final states = <AsyncValue<void>>[];

      // Listen auf State-Änderungen
      container.listen(
        recipeUploadProvider,
        (previous, next) {
          states.add(next);
        },
      );

      when(mockRepo.saveRecipe(any, any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return 'test-recipe-id';
      });

      // Act
      await container
          .read(recipeUploadProvider.notifier)
          .uploadRecipe(recipe, null);

      // Assert - prüfe alle States
      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0].isLoading, true); // Erster State = loading
      expect(states.last.hasValue, true); // Letzter State = data
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      final recipe = Recipe(
        name: 'Test Recipe',
        categories: ['Test'],
        portions: 4,
        ingredients: [],
        instructions: 'Test',
      );

      when(mockRepo.saveRecipe(any, any))
          .thenAnswer((_) async => 'test-recipe-id');

      // Act
      await container
          .read(recipeUploadProvider.notifier)
          .uploadRecipe(recipe, null);

      // Assert
      verify(mockRepo.saveRecipe(recipe, null)).called(1);
    });

    test('should handle errors correctly', () async {
      // Arrange
      final recipe = Recipe(
        name: 'Test Recipe',
        categories: ['Test'],
        portions: 4,
        ingredients: [],
        instructions: 'Test',
      );

      when(mockRepo.saveRecipe(any, any)).thenThrow(Exception('Upload failed'));

      // Act
      await container
          .read(recipeUploadProvider.notifier)
          .uploadRecipe(recipe, null);

      // Assert
      final state = container.read(recipeUploadProvider);
      expect(state, isA<AsyncError>());
      expect(state.hasError, true);
    });
  });
}
