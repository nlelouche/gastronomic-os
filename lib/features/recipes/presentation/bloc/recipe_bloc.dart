import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final IRecipeRepository repository;
  final IInventoryRepository inventoryRepository;
  final IOnboardingRepository onboardingRepository;

  final DietEngine _dietEngine = DietEngine();
  final ScoringEngine _scoringEngine = ScoringEngine();

  RecipeBloc({
    required this.repository,
    required this.inventoryRepository,
    required this.onboardingRepository,
  }) : super(RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<ForkRecipe>(_onForkRecipe);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<SeedDatabase>(_onSeedDatabase);
    on<FilterRecipes>(_onFilterRecipes);
  }

  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    // Keep filter state if possible? 
    // Usually navigating to detail doesn't clear the list state unless we emit Loading and replace everything.
    // But RecipeDetailLoaded replaces the whole state. 
    // If we return, we might lose the filter.
    // Ideally, Details should be handled by a separate Bloc or just a FutureBuilder if we want to preserve the List state in the background.
    // However, for now, let's follow existing pattern.
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
      final list = result.$2!;
      emit(RecipeLoaded(
        recipes: list, 
        allRecipes: list
      ));
    }
  }

  Future<void> _onFilterRecipes(FilterRecipes event, Emitter<RecipeState> emit) async {
    if (state is! RecipeLoaded) return;
    final currentState = state as RecipeLoaded;
    
    // Start with full list
    var filtered = List<Recipe>.from(currentState.allRecipes);

    // 1. Text Search / Query
    if (event.query.isNotEmpty) {
       filtered = filtered.where((r) => r.title.toLowerCase().contains(event.query.toLowerCase())).toList();
    }

    // 2. Ingredients
    if (event.requiredIngredients.isNotEmpty) {
       filtered = filtered.where((r) => 
          event.requiredIngredients.every((req) => 
             r.ingredients.any((ing) => ing.toLowerCase().contains(req.toLowerCase()))
          )
       ).toList();
    }

    // 3. Family Safe
    if (event.isFamilySafe) {
        final familyResult = await onboardingRepository.getFamilyMembers();
        if (familyResult.$2 != null) {
            final family = familyResult.$2!;
            filtered = filtered.where((r) => _dietEngine.areRecipesCompatible(r, family)).toList();
        }
    }

    // 4. Pantry Ready (Best Match)
    if (event.isPantryReady) {
        final invResult = await inventoryRepository.getInventory();
        if (invResult.$2 != null) {
            final inventory = invResult.$2!;
            // Sort by score
            filtered.sort((a, b) {
                final scoreA = _scoringEngine.calculateScore(a, inventory);
                final scoreB = _scoringEngine.calculateScore(b, inventory);
                return scoreB.compareTo(scoreA); // Descending
            });
        }
    }

    emit(currentState.copyWith(
       recipes: filtered,
       isFamilySafe: event.isFamilySafe,
       isPantryReady: event.isPantryReady,
       query: event.query,
       requiredIngredients: event.requiredIngredients
    ));
  }

  Future<void> _onCreateRecipe(CreateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.createRecipe(event.recipe);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      add(LoadRecipes());
    }
  }

  Future<void> _onForkRecipe(ForkRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.forkRecipe(event.originalRecipeId, event.newTitle);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      add(LoadRecipes());
    }
  }

  Future<void> _onSeedDatabase(SeedDatabase event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      await repository.seedDatabase(filterTitle: event.filterTitle);
      add(LoadRecipes());
    } catch (e) {
      emit(RecipeError('Failed to seed database: $e'));
    }
  }
}
