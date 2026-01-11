import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final IRecipeRepository repository;

  RecipeBloc({required this.repository}) : super(RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<ForkRecipe>(_onForkRecipe);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<SeedDatabase>(_onSeedDatabase);
  }

  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.getRecipeDetails(event.recipeId);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeDetailLoaded(result.$2!));
    }
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.getRecipes(); // Returns (Failure?, List<Recipe>?)
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeLoaded(result.$2!));
    }
  }

  Future<void> _onCreateRecipe(CreateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.createRecipe(event.recipe);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      // Reload recipes to show the new one
      add(LoadRecipes());
    }
  }

  Future<void> _onForkRecipe(ForkRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.forkRecipe(event.originalRecipeId, event.newTitle);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      // Reload to show the forked recipe in the list
      add(LoadRecipes());
    }
  }

  Future<void> _onSeedDatabase(SeedDatabase event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      await repository.seedDatabase(filterTitle: event.filterTitle);
      // Reload recipes to show the new seeded recipes
      add(LoadRecipes());
    } catch (e) {
      emit(RecipeError('Failed to seed database: $e'));
    }
  }
}
