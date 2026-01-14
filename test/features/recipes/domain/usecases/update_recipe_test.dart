import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/usecases/update_recipe.dart'; // Will exist soon

class MockRecipeRepository extends Mock implements IRecipeRepository {}
class FakeRecipe extends Fake implements Recipe {}

void main() {
  late UpdateRecipe usecase;
  late MockRecipeRepository mockRecipeRepository;

  setUpAll(() {
    registerFallbackValue(FakeRecipe());
  });

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    usecase = UpdateRecipe(mockRecipeRepository);
  });

  final tRecipe = FakeRecipe();

  test(
    'should call updateRecipe from the repository',
    () async {
      // arrange
      when(() => mockRecipeRepository.updateRecipe(any()))
          .thenAnswer((_) async => (null, tRecipe));

      // act
      final result = await usecase(tRecipe);

      // assert
      expect(result, (null, tRecipe));
      verify(() => mockRecipeRepository.updateRecipe(any())).called(1);
      verifyNoMoreInteractions(mockRecipeRepository);
    },
  );
  
  test(
    'should bubble up failures',
    () async {
      // arrange
      final tFailure = ServerFailure('Update Failed', context: ErrorContext.repository('updateRecipe'));
      when(() => mockRecipeRepository.updateRecipe(any()))
          .thenAnswer((_) async => (tFailure, null));

      // act
      final result = await usecase(tRecipe);

      // assert
      expect(result, (tFailure, null));
    },
  );
}
