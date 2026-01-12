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
    on<LoadMoreRecipes>(_onLoadMoreRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<ForkRecipe>(_onForkRecipe);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<SeedDatabase>(_onSeedDatabase);
    on<FilterRecipes>(_onFilterRecipes);
  }

  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    // Keep state if possible, or just emit loading
    emit(RecipeLoading()); // Simplification for now
    final result = await repository.getRecipeDetails(event.recipeId);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeDetailLoaded(result.$2!));
    }
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    // Initial Load: Offset 0, Limit 20
    final result = await repository.getRecipes(limit: 20, offset: 0); 
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      final list = result.$2!;
      emit(RecipeLoaded(
        recipes: list,
        hasReachedMax: list.length < 20,
      ));
    }
  }

  Future<void> _onLoadMoreRecipes(LoadMoreRecipes event, Emitter<RecipeState> emit) async {
    if (state is! RecipeLoaded) return;
    final currentState = state as RecipeLoaded;
    if (currentState.hasReachedMax) return;

    final currentLen = currentState.recipes.length;
    // Fetch next page
    final result = await repository.getRecipes(
      limit: 20, 
      offset: currentLen,
      query: currentState.query // Maintain current search query!
    );

    if (result.$1 != null) {
      // Create a minor error side-effect or just ignore?
      // Usually we don't break the whole view. 
      // For now, let's just do nothing or store error in a separate field (not defined yet).
      // Or emit same state.
    } else {
      final newRecipes = result.$2!;
      emit(currentState.copyWith(
        recipes: currentState.recipes + newRecipes,
        hasReachedMax: newRecipes.length < 20,
      ));
    }
  }

  Future<void> _onFilterRecipes(FilterRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    
    // Server-Side Search for Text Query
    // We reset pagination (offset 0)
    final result = await repository.getRecipes(
      limit: 20, 
      offset: 0,
      query: event.query
    );

    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      final list = result.$2!;
      // Client-side filtering for other flags (Family/Pantry) on this page?
      // Plan Phase 2 says: "Filter Implications... server-side search" for text.
      // It doesn't explicitly solve Family/Pantry for the whole DB.
      // So we apply it to the returned page for now, or ignore it?
      // If we apply it to the page, we might get 0 results on Page 1 even if Page 2 has them.
      // This is a known limitation until Phase 3 (Scoring Engine).
      // Let's apply it simply to the current fetched batch so features don't look broken.
      
      var filtered = list;

      // 3. Family Safe
      if (event.isFamilySafe) {
          final familyResult = await onboardingRepository.getFamilyMembers();
          if (familyResult.$2 != null) {
              final family = familyResult.$2!;
              filtered = filtered.where((r) => _dietEngine.areRecipesCompatible(r, family)).toList();
          }
      }

      // 4. Pantry Ready
      // ... (Same limitation, applied to batch)
       if (event.isPantryReady) {
          final invResult = await inventoryRepository.getInventory();
          if (invResult.$2 != null) {
              final inventory = invResult.$2!;
              // Sort batch by score
              filtered.sort((a, b) {
                  final scoreA = _scoringEngine.calculateScore(a, inventory);
                  final scoreB = _scoringEngine.calculateScore(b, inventory);
                  return scoreB.compareTo(scoreA); // Descending
              });
          }
      }

      emit(RecipeLoaded(
        recipes: filtered,
        hasReachedMax: list.length < 20, // Based on FETCHED count, not filtered count
        query: event.query,
        isFamilySafe: event.isFamilySafe,
        isPantryReady: event.isPantryReady,
        requiredIngredients: event.requiredIngredients
      ));
    }
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
