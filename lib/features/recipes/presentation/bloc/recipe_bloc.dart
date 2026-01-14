import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_debug_service.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final IRecipeRepository repository;
  final IInventoryRepository inventoryRepository;
  final IOnboardingRepository onboardingRepository;
  final RecipeDebugService debugService;

  final DietEngine _dietEngine = DietEngine();
  final ScoringEngine _scoringEngine = ScoringEngine();

  RecipeBloc({
    required this.repository,
    required this.inventoryRepository,
    required this.onboardingRepository,
    required this.debugService,
  }) : super(RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadMoreRecipes>(_onLoadMoreRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<ForkRecipe>(_onForkRecipe);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<SeedDatabase>(_onSeedDatabase);
    on<FilterRecipes>(_onFilterRecipes);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<ToggleSaveRecipe>(_onToggleSaveRecipe);
  }

  Future<void> _onDeleteRecipe(DeleteRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.deleteRecipe(event.recipeId);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeDeleted());
      // Optionally reload list if we were on list view, but usually we pop details
      add(LoadRecipes()); 
    }
  }


  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.getRecipeDetails(event.recipeId);
    
    // Check if recipe is saved by current user
    final isSavedResult = await repository.isRecipeSaved(event.recipeId);
    final bool isSaved = isSavedResult.$2 ?? false;

    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeDetailLoaded(result.$2!, isSaved: isSaved));
    }
  }

  Future<void> _onToggleSaveRecipe(ToggleSaveRecipe event, Emitter<RecipeState> emit) async {
    if (state is RecipeDetailLoaded) {
      final currentState = state as RecipeDetailLoaded;
      
      // Optimistic update
      emit(RecipeDetailLoaded(currentState.recipe, isSaved: !currentState.isSaved));
      
      final result = await repository.toggleSaveRecipe(event.recipeId);
      
      if (result.$1 != null) {
        // Revert on failure
        emit(RecipeDetailLoaded(currentState.recipe, isSaved: currentState.isSaved));
        emit(RecipeError(result.$1!.message));
      }
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
    // 1. Prepare Server-Side Filters
    List<String>? excludedTags;
    
    if (event.isFamilySafe) {
        final familyResult = await onboardingRepository.getFamilyMembers();
        if (familyResult.$2 != null) {
            final family = familyResult.$2!;
            // Simple mapping for Server-Side Exclusion (Optimization)
            // Complex logic still happens in DietEngine, but this reduces "Definite No's"
            excludedTags = [];
            for (var member in family) {
                for (var condition in member.medicalConditions) {
                    // Map MedicalCondition to approximate excluded tags
                    // NOTE: This assumes we tag unsafe recipes.
                    // Ideally, we'd filter by "Allowed Tags", but exclusionary is safer for now.
                    // This is a placeholder for the Audit Fix.
                    // if (condition == MedicalCondition.celiac) excludedTags.add('Gluten'); 
                    // if (condition == MedicalCondition.nutAllergy) excludedTags.add('Peanuts');
                    // For now, let's keep it null safe as the DB tags aren't fully standardized.
                }
            }
        }
    }

    // 2. Fetch from Repo with Filters
    final result = await repository.getRecipes(
      limit: 20, 
      offset: 0,
      query: event.query,
      excludedTags: excludedTags,
    );

    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      var list = result.$2!;
      
      // 3. Apply Strict Client-Side Filtering (DietEngine)
      // We still need this because Tags are coarse, but DietEngine is precise.
      if (event.isFamilySafe && event.isFamilySafe) { // Redundant check for clarity
           final familyResult = await onboardingRepository.getFamilyMembers();
           if (familyResult.$2 != null) {
               list = list.where((r) => _dietEngine.isRecipeCompatible(r, familyResult.$2!)).toList();
           }
      }

      // 4. Pantry Ready Sort
       if (event.isPantryReady) {
          final invResult = await inventoryRepository.getInventory();
          if (invResult.$2 != null) {
              final inventory = invResult.$2!;
              list.sort((a, b) {
                  final scoreA = _scoringEngine.calculateScore(a, inventory);
                  final scoreB = _scoringEngine.calculateScore(b, inventory);
                  return scoreB.compareTo(scoreA); 
              });
          }
      }

      emit(RecipeLoaded(
        recipes: list,
        hasReachedMax: list.length < 20, 
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

  Future<void> _onUpdateRecipe(UpdateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.updateRecipe(event.recipe);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      // Don't trigger LoadRecipes() here as it switches state to RecipeLoaded (List)
      // causing the Detail Page to lose context and show "Initializing..."
      // Just emit DetailLoaded with the updated recipe.
      // add(LoadRecipes()); // REMOVED
      
      // Update details to show new data immediately
      emit(RecipeDetailLoaded(event.recipe)); 
    }
  }

  Future<void> _onForkRecipe(ForkRecipe event, Emitter<RecipeState> emit) async {
    // Capture current recipe to preserve state
    Recipe? currentRecipe;
    if (state is RecipeDetailLoaded) {
      currentRecipe = (state as RecipeDetailLoaded).recipe;
    }
    
    emit(RecipeLoading());
    final result = await repository.forkRecipe(event.originalRecipeId, event.newTitle);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
      // Restore state if possible
      if (currentRecipe != null) emit(RecipeDetailLoaded(currentRecipe));
    } else {
      // Emit Forked event with BOTH recipes
      if (currentRecipe != null) {
         emit(RecipeForked(newRecipe: result.$2!, originalRecipe: currentRecipe));
         // Optional: Immediately restore Loaded state so "Back" works perfectly without depending on Forked state persistence
         // emit(RecipeDetailLoaded(currentRecipe)); 
         // Actually, if we emit Loaded immediately, the Listener might miss 'Forked' if it's too fast? 
         // Bloc listeners are synchronous stream subscriptions usually.
         // Safest is to let the UI handle Forked state as a "Loaded" variant.
      } else {
         // Fallback if we weren't in Detail view (shouldn't happen in this flow)
         add(LoadRecipes());
      }
    }
  }

  Future<void> _onSeedDatabase(SeedDatabase event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      await debugService.seedDatabase(filterTitle: event.filterTitle);
      add(LoadRecipes());
    } catch (e) {
      emit(RecipeError('Failed to seed database: $e'));
    }
  }
}
