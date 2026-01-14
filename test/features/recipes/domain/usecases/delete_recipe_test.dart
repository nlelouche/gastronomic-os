import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/recipes/domain/usecases/delete_recipe.dart';

class MockRecipeRepository extends Mock implements IRecipeRepository {}

void main() {
  late DeleteRecipe usecase;
  late MockRecipeRepository mockRecipeRepository;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    usecase = DeleteRecipe(mockRecipeRepository);
  });

  final tRecipeId = 'test_recipe_id';

  test(
    'should call deleteRecipe from the repository',
    () async {
      // arrange
      // Method signature is Future<(Failure?, void)>
      when(() => mockRecipeRepository.deleteRecipe(any()))
          .thenAnswer((_) async => (null, null));

      // act
      final result = await usecase(tRecipeId);

      // assert
      expect(result, (null, null));
      verify(() => mockRecipeRepository.deleteRecipe(tRecipeId));
      verifyNoMoreInteractions(mockRecipeRepository);
    },
  );
  
  test(
    'should bubble up failures from the repository',
    () async {
      // arrange
      final tFailure = ServerFailure('Server Error', context: ErrorContext.repository('deleteRecipe'));
      when(() => mockRecipeRepository.deleteRecipe(any()))
          .thenAnswer((_) async => (tFailure, null));

      // act
      final result = await usecase(tRecipeId);

      // assert
      expect(result, (tFailure, null));
      verify(() => mockRecipeRepository.deleteRecipe(tRecipeId));
    },
  );
}
