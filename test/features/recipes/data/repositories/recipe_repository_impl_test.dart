import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
class MockRecipeRemoteDataSource extends Mock implements RecipeRemoteDataSource {}
class MockRecipeCacheService extends Mock implements RecipeCacheService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockRecipeModel extends Mock implements RecipeModel {}

void main() {
  late RecipeRepositoryImpl repository;
  late MockRecipeRemoteDataSource mockRemoteDataSource;
  late MockRecipeCacheService mockCacheService;
  late MockSupabaseClient mockSupabaseClient;

  // Helper to create a valid Recipe
  Recipe createTestRecipe() => Recipe(
        id: 'test_id',
        authorId: 'user_1',
        title: 'Test Recipe',
        ingredients: const [],
        steps: const [],
        tags: const [],
        dietTags: const [],
        createdAt: DateTime.now(),
      );

  setUpAll(() {
    registerFallbackValue(createTestRecipe());
  });

  setUp(() {
    mockRemoteDataSource = MockRecipeRemoteDataSource();
    mockCacheService = MockRecipeCacheService();
    mockSupabaseClient = MockSupabaseClient();
    repository = RecipeRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      supabaseClient: mockSupabaseClient,
      cacheService: mockCacheService,
    );
  });

  final tRecipeId = 'test_id';

  test('deleteRecipe should call remoteDataSource.deleteRecipe and invalidate cache', () async {
    // arrange
    when(() => mockRemoteDataSource.deleteRecipe(any())).thenAnswer((_) async {});
    when(() => mockCacheService.invalidate()).thenReturn(null);

    // act
    final result = await repository.deleteRecipe(tRecipeId);

    // assert
    expect(result, (null, null));
    verify(() => mockRemoteDataSource.deleteRecipe(tRecipeId)).called(1);
    verify(() => mockCacheService.invalidate()).called(1);
  });

  test('deleteRecipe should return Failure when datasource fails', () async {
    // arrange
    when(() => mockRemoteDataSource.deleteRecipe(any())).thenThrow(Exception('Delete failed'));
    
    // act
    final result = await repository.deleteRecipe(tRecipeId);

    // assert
    expect(result.$1, isA<Failure>()); // Check that failure is present
    verify(() => mockRemoteDataSource.deleteRecipe(tRecipeId)).called(1);
  });
  
  test('updateRecipe should call remoteDataSource.updateRecipe and invalidate cache', () async {
    // arrange
    final tRecipe = createTestRecipe();
    final tRecipeModel = MockRecipeModel();
    
    when(() => mockRemoteDataSource.updateRecipe(any())).thenAnswer((_) async => tRecipeModel);
    when(() => mockCacheService.invalidate()).thenReturn(null);

    // act
    final result = await repository.updateRecipe(tRecipe);

    // assert
    expect(result, (null, tRecipeModel));
    verify(() => mockRemoteDataSource.updateRecipe(tRecipe)).called(1);
    verify(() => mockCacheService.invalidate()).called(1);
  });
}
