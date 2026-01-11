import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_snapshot_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/commit_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart'; 

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes();
  Future<RecipeModel> createRecipe(Recipe recipe);
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId);
  Future<List<CommitModel>> getCommits(String recipeId);
  Future<CommitModel> addCommit(CommitModel commit);
  Future<RecipeModel> getRecipeDetails(String recipeId);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final SupabaseClient supabaseClient;

  RecipeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await supabaseClient.from('recipes').select(); // RLS handles filtering
      return (response as List).map((e) => RecipeModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerFailure();
    }
  }

  @override
  Future<RecipeModel> createRecipe(Recipe recipe) async {
    try {
      // 1. Insert Recipe Header
      // We don't send ingredients/steps here as they are not in 'recipes' table
      final recipeData = {
        'title': recipe.title,
        'description': recipe.description,
        'is_public': recipe.isPublic,
        'author_id': supabaseClient.auth.currentUser!.id,
      };

      final recipeResponse = await supabaseClient
          .from('recipes')
          .insert(recipeData)
          .select()
          .single();
      
      final recipeId = recipeResponse['id'];

      // 2. Insert Initial Commit
      final commitData = {
        'recipe_id': recipeId,
        'author_id': supabaseClient.auth.currentUser!.id,
        'message': 'Initial commit',
        'diff': {'action': 'init'}, // Simplified diff for init
      };

      final commitResponse = await supabaseClient
          .from('commits')
          .insert(commitData)
          .select()
          .single();
      
      final commitId = commitResponse['id'];

      // 3. Insert Snapshot (The Content)
      final snapshotData = {
        'commit_id': commitId,
        'recipe_id': recipeId,
        'full_structure': {
          'ingredients': recipe.ingredients,
          'steps': recipe.steps,
        },
      };

      await supabaseClient
          .from('recipe_snapshots')
          .insert(snapshotData);

      // Return the created model (header only, ingredients loaded separately if needed)
      return RecipeModel.fromJson(recipeResponse);
    } catch (e) {
      // In a real app we would rollback/delete created items if a step fails
      print('Error creating recipe: $e'); 
      throw const ServerFailure();
    }
  }

  @override
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId) async {
    try {
      // 1. Fetch original recipe to copy description/logic if needed (optional)
      // 2. Insert new recipe pointing to origin
      final forkData = {
        'author_id': authorId,
        'origin_id': originalRecipeId,
        'is_fork': true,
        'title': newTitle,
        'is_public': true, // Default
      };
      
      final response = await supabaseClient
          .from('recipes')
          .insert(forkData)
          .select()
          .single();
          
      return RecipeModel.fromJson(response);
    } catch (e) {
      throw const ServerFailure();
    }
  }

  @override
  Future<List<CommitModel>> getCommits(String recipeId) async {
    try {
      final response = await supabaseClient
          .from('commits')
          .select()
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => CommitModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerFailure();
    }
  }

  @override
  Future<CommitModel> addCommit(CommitModel commit) async {
    try {
      final response = await supabaseClient
          .from('commits')
          .insert(commit.toJson()..remove('id'))
          .select()
          .single();
      return CommitModel.fromJson(response);
    } catch (e) {
      throw const ServerFailure();
    }
  }

  @override
  Future<RecipeModel> getRecipeDetails(String recipeId) async {
    try {
      // 1. Fetch the Recipe Header
      final recipeResponse = await supabaseClient
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();
      
      final recipeModel = RecipeModel.fromJson(recipeResponse);

      // 2. Fetch the Latest Snapshot
      // We assume the latest snapshot corresponds to the current state
      final snapshotResponse = await supabaseClient
          .from('recipe_snapshots')
          .select()
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (snapshotResponse != null) {
        final snapshot = RecipeSnapshotModel.fromJson(snapshotResponse);
        // Return a new model with ingredients/steps populated
        return RecipeModel(
          id: recipeModel.id,
          authorId: recipeModel.authorId,
          originId: recipeModel.originId,
          isFork: recipeModel.isFork,
          title: recipeModel.title,
          description: recipeModel.description,
          isPublic: recipeModel.isPublic,
          createdAt: recipeModel.createdAt,
          ingredients: snapshot.ingredients,
          steps: snapshot.steps,
        );
      }
      
      return recipeModel; // Return header only if no snapshot found
    } catch (e) {
      print('Error fetching details: $e');
      throw const ServerFailure();
    }
  }
}
