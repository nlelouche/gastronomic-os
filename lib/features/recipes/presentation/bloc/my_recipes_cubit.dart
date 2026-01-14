import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/my_recipes_state.dart';

class MyRecipesCubit extends Cubit<MyRecipesState> {
  final IRecipeRepository repository;

  MyRecipesCubit(this.repository) : super(MyRecipesInitial());

  Future<void> loadMyRecipes() async {
    emit(MyRecipesLoading());

    // Execute fetches in parallel for performance
    final results = await Future.wait([
      repository.getMyRecipes(isFork: false), // Created
      repository.getMyRecipes(isFork: true),  // Forked
      repository.getSavedRecipes(),           // Saved
    ]);

    final createdResult = results[0];
    final forkedResult = results[1];
    final savedResult = results[2];

    // Check for errors (fail if any critical fetch fails)
    if (createdResult.$1 != null) {
        emit(MyRecipesError(createdResult.$1!.message));
        return;
    }

    emit(MyRecipesLoaded(
      createdRecipes: createdResult.$2 ?? [],
      forkedRecipes: forkedResult.$2 ?? [],
      savedRecipes: savedResult.$2 ?? [],
    ));
  }
}
