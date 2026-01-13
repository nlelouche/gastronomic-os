import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';

/// A dedicated service for managing Recipe Caching logic.
/// Currently uses In-Memory caching, but can be extended to use Hive/SQL.
class RecipeCacheService {
  List<Recipe>? _recipes;
  final Map<String, Recipe> _detailsCache = {};
  
  // configurable TTL (Time To Live). 5 minutes for now.
  static const Duration _cacheDuration = Duration(minutes: 5);
  DateTime? _lastFetchTime;

  bool get isValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  void cacheRecipes(List<Recipe> list) {
    _recipes = list;
    _lastFetchTime = DateTime.now();
    // Also populate details cache for quick lookup
    for (var r in list) {
       _detailsCache[r.id] = r;
    }
    AppLogger.d('📦 CacheService: Cached ${list.length} recipes.');
  }

  List<Recipe>? getCachedRecipes() {
    if (!isValid) {
      AppLogger.d('📦 CacheService: Cache expired or empty.');
      invalidate();
      return null;
    }
    return _recipes;
  }

  void cacheRecipeDetails(Recipe recipe) {
    _detailsCache[recipe.id] = recipe;
    // Update list if exists
    if (_recipes != null) {
      final index = _recipes!.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes![index] = recipe;
      } else {
        _recipes!.add(recipe);
      }
    }
  }

  Recipe? getRecipeDetails(String id) {
    return _detailsCache[id];
  }

  void invalidate() {
    _recipes = null;
    _lastFetchTime = null;
    _detailsCache.clear();
    AppLogger.d('📦 CacheService: Invalidated.');
  }
}
