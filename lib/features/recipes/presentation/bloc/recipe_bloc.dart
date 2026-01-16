import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/error/failures.dart'; // Added Import
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_debug_service.dart';
import 'package:gastronomic_os/features/recipes/data/services/recipe_importer_service.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final IRecipeRepository repository;
  final IInventoryRepository inventoryRepository;
  final IOnboardingRepository onboardingRepository;
  final RecipeDebugService debugService;
  final RecipeImporterService importerService;

  final DietEngine _dietEngine = DietEngine();
  final ScoringEngine _scoringEngine = ScoringEngine();

  RecipeBloc({
    required this.repository,
    required this.inventoryRepository,
    required this.onboardingRepository,
    required this.debugService,
    required this.importerService,
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
    on<ClearAllRecipes>(_onClearAllRecipes);
  }

  Future<void> _onClearAllRecipes(ClearAllRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      await debugService.clearDatabase();
      emit(const RecipeLoaded(recipes: [])); 
    } catch (e) {
      emit(RecipeError('Failed to clear database: $e'));
    }
  }

  Future<void> _onDeleteRecipe(DeleteRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.deleteRecipe(event.recipeId);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      emit(RecipeDeleted());
      // Optionally reload list if we were on list view, but usually we pop details
      // Optionally reload list if we were on list view, but usually we pop details
      String languageCode = 'es'; 
      if (state is RecipeLoaded) {
        languageCode = (state as RecipeLoaded).languageCode ?? 'es';
      }
      add(LoadRecipes(languageCode: languageCode)); 
    }
  }


  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    // 1. Fetch Main Recipe
    final result = await repository.getRecipeDetails(event.recipeId);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
      return;
    }
    
    final recipe = result.$2!;

    // 2. Fetch Lineage concurrently
    // - Is Saved?
    // - Parent Recipe (if originId exists)
    // - Forks (Children)
    
    final results = await Future.wait([
      repository.isRecipeSaved(event.recipeId),
      recipe.originId != null ? repository.getRecipeDetails(recipe.originId!) : Future.value((null, null)),
      repository.getForks(event.recipeId),
    ]);

    final isSavedResult = results[0] as (Failure?, bool);
    final parentResult = results[1] as (Failure?, Recipe?);
    final forksResult = results[2] as (Failure?, List<Recipe>?);

    emit(RecipeDetailLoaded(
      recipe, 
      isSaved: isSavedResult.$2 ?? false,
      parentRecipe: parentResult.$2, // Null if failure or no origin
      forks: forksResult.$2 ?? [],
    ));
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
    final result = await repository.getRecipes(
      limit: 20, 
      offset: 0,
      collectionId: event.collectionId, // Pass optional collectionId
      languageCode: event.languageCode, // Pass language code
    ); 
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      final list = result.$2!;
      emit(RecipeLoaded(
        recipes: list,
        hasReachedMax: list.length < 20,
        languageCode: event.languageCode, // Persist it
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
    // 1. Prepare Server-Side Filters (Family Safe)
    List<String>? excludedTags;
    
    if (event.isFamilySafe) {
        final familyResult = await onboardingRepository.getFamilyMembers();
        if (familyResult.$2 != null) {
            final family = familyResult.$2!;
            // TODO: Implement proper tag mapping based on medical conditions
            // excludedTags = ...
        }
    }

    // 2. Prepare Pantry Items for Sorting
    List<String>? pantryItems;
    if (event.isPantryReady) {
       final invResult = await inventoryRepository.getInventory();
       if (invResult.$2 != null) {
          pantryItems = invResult.$2!.map((e) => e.name).toList();
       }
    }

    // 3. Fetch from Repo with Filters & Pantry Sorting
    String? languageCode;
    if (state is RecipeLoaded) {
      languageCode = (state as RecipeLoaded).languageCode;
    }
    
    // Explicitly check for null languageCode if we expect it to be always set
    if (languageCode == null) {
       // This shouldn't happen if LoadRecipes was called first correctly. 
       // But if it does, we might want to default or log warning.
       // AppLogger.w('FilterRecipes called without active language code in state!');
    }

    final result = await repository.getRecipes(
      limit: 20, 
      offset: 0,
      query: event.query,
      excludedTags: excludedTags,
      pantryItems: pantryItems, // Pass items for sorting
      languageCode: languageCode, // Use persisted language
    );

    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      var list = result.$2!;
      
      // 4. Client-Side Strict Diet Filtering (Still needed for precision)
      if (event.isFamilySafe) { 
           final familyResult = await onboardingRepository.getFamilyMembers();
           if (familyResult.$2 != null) {
               list = list.where((r) => _dietEngine.isRecipeCompatible(r, familyResult.$2!)).toList();
           }
      }

      emit(RecipeLoaded(
        recipes: list,
        hasReachedMax: list.length < 20, 
        query: event.query,
        isFamilySafe: event.isFamilySafe,
        isPantryReady: event.isPantryReady,
        requiredIngredients: event.requiredIngredients,
        languageCode: languageCode, // Keep it for next filters
      ));
    }
  }

  Future<void> _onCreateRecipe(CreateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    final result = await repository.createRecipe(event.recipe);
    
    if (result.$1 != null) {
      emit(RecipeError(result.$1!.message));
    } else {
      String languageCode = 'es';
      if (state is RecipeLoaded) {
        languageCode = (state as RecipeLoaded).languageCode ?? 'es';
      }
      add(LoadRecipes(languageCode: languageCode));
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
         String? languageCode;
         if (state is RecipeLoaded) {
           languageCode = (state as RecipeLoaded).languageCode;
         }
         add(LoadRecipes(languageCode: languageCode ?? 'es'));
      }
    }
  }

  Future<void> _onSeedDatabase(SeedDatabase event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      // Use the new Importer Service instead of DebugService
      final stats = await importerService.importMasterRecipes();
      
      // We could add a specific event/state to show a Snackbar, 
      // but for now we just reload and maybe log it.
      // Since this is a "Debug" action, a console log or simple reload is acceptable.
      // Ideally, emit(RecipeLoaded...) but we want to show a message?
      // Don't auto-load here blindly. Emit Loaded with empty list if needed, or rely on UI to refresh.
      // But if we do refresh, we MUST use a valid language code. 
      // We cannot get context here easily.
      // If state has language, use it. If not, we are in a bind. 
      // For seeding, it's safer to NOT trigger a load and let the UI (SettingsPage) handle the success feedback.
      // If we MUST reload, use existing language code if available
      if (state is RecipeLoaded) {
          final lang = (state as RecipeLoaded).languageCode;
          if (lang != null) {
             add(LoadRecipes(languageCode: lang));
          } else {
             emit(RecipeInitial()); // Reset if lost
          }
      } else {
        // If unknown state, just emit Initial so UI knows to reset/re-init if needed
        emit(RecipeInitial());
      }
    } catch (e) {
      emit(RecipeError('Failed to import recipes: $e'));
    }
  }
}
