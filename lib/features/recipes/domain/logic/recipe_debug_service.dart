import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_seeder.dart';

class RecipeDebugService {
  final RecipeRemoteDataSource remoteDataSource;

  RecipeDebugService({required this.remoteDataSource});

  Future<void> seedDatabase({String? filterTitle}) async {
    AppLogger.w('🧹 Clearing existing recipes...');
    
    try {
      if (filterTitle == null) {
         await remoteDataSource.clearAllRecipes();
         AppLogger.i('✅ Database cleared');
      } else {
        AppLogger.i('ℹ️ Single recipe seed mode - Skipping full database clear');
      }

    } catch (e, stackTrace) {
      AppLogger.e('⚠️ Error clearing database', e, stackTrace);
    }

    AppLogger.i('🌱 Seeding recipes${filterTitle != null ? ' (Filter: $filterTitle)' : ''}...');
    final recipes = await RecipeSeeder.loadFromAssets(filterTitle: filterTitle);
    
    for (final recipe in recipes) {
      try {
        await remoteDataSource.createRecipe(recipe);
        AppLogger.i('✓ Seeded: ${recipe.title}');
      } catch (e) {
        AppLogger.e('✗ Error seeding recipe ${recipe.title}', e);
      }
    }
    AppLogger.i('🎉 Seeding complete!');
  }
}
