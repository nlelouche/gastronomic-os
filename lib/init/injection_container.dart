import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/bloc/theme_cubit.dart';
import 'package:gastronomic_os/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:gastronomic_os/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:gastronomic_os/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/my_recipes_cubit.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/usecases/manage_collections.dart';
import 'package:gastronomic_os/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:gastronomic_os/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/planner/domain/usecases/get_meal_suggestions.dart';
import 'package:gastronomic_os/features/planner/domain/repositories/i_meal_plan_repository.dart';
import 'package:gastronomic_os/features/planner/data/repositories/meal_plan_repository_impl.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/domain/logic/shopping_engine.dart';
import 'package:gastronomic_os/core/bloc/localization_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_debug_service.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_cache_service.dart'; // NEW

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Inventory
  // Repository
  sl.registerLazySingleton<IInventoryRepository>(
    () => InventoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IRecipeRepository>(
    () => RecipeRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl(), cacheService: sl()),
  );

  // Features - Collections (Phase 3.4)
  sl.registerLazySingleton(() => CreateCollection(sl()));
  sl.registerLazySingleton(() => GetUserCollections(sl()));
  sl.registerLazySingleton(() => AddToCollection(sl()));
  sl.registerLazySingleton(() => RemoveFromCollection(sl()));
  sl.registerLazySingleton(() => DeleteCollection(sl()));

  // Data sources
  sl.registerLazySingleton(() => RecipeCacheService()); // NEW
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ! Presentation
  sl.registerFactory(() => InventoryBloc(repository: sl()));
  sl.registerFactory(() => RecipeBloc(
    repository: sl(),
    inventoryRepository: sl(),
    onboardingRepository: sl(),
    debugService: sl(),
  ));
  sl.registerFactory(() => MyRecipesCubit(sl())); 
  sl.registerFactory(() => CollectionsBloc(
    getUserCollections: sl(),
    createCollection: sl(),
    addToCollection: sl(),
    removeFromCollection: sl(),
    deleteCollection: sl(),
  ));
  sl.registerFactory(() => OnboardingBloc(repository: sl()));

  // Onboarding Feature
  sl.registerLazySingleton<IOnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Planner Feature
  sl.registerLazySingleton(() => GetMealSuggestions(
    recipeRepository: sl(),
    inventoryRepository: sl(),
    onboardingRepository: sl(),
  ));

  sl.registerLazySingleton<IMealPlanRepository>(
      () => MealPlanRepositoryImpl(sl()));

  sl.registerLazySingleton(() => ShoppingEngine());
  sl.registerLazySingleton(() => RecipeDebugService(remoteDataSource: sl()));
  
  sl.registerFactory(() => PlannerBloc(
    getMealSuggestions: sl(),
    mealPlanRepository: sl(),
    inventoryRepository: sl(),
    shoppingEngine: sl(),
  ));
  sl.registerFactory(() => LocalizationBloc());
  sl.registerFactory(() => ThemeCubit());

  // ! External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
