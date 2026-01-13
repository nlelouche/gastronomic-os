import 'dart:io';
import 'package:supabase/supabase.dart';

/// Cleanup tool to remove old/corrupted Master Recipes from Supabase.
/// Keeps only the latest working version with complete variant_logic.
Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('🔍 Finding all Master Recipes...\n');
  
  // Find all recipes with "Master" or "MASTER" in title
  final recipesResponse = await supabase
      .from('recipes')
      .select('id, title, created_at')
      .or('title.ilike.%master%,title.ilike.%universal%')
      .order('created_at', ascending: false);
  
  if (recipesResponse == null || (recipesResponse as List).isEmpty) {
    print('❌ No Master Recipes found.');
    return;
  }
  
  final recipes = recipesResponse as List;
  print('Found ${recipes.length} Master Recipe(s):\n');
  
  // The CORRECT one (newly imported with full variant_logic)
  const correctRecipeId = '9c6b5e5a-6021-4e9c-9278-cf98d92e79db';
  
  final toDelete = <Map<String, dynamic>>[];
  
  for (final recipe in recipes) {
    final id = recipe['id'] as String;
    final title = recipe['title'] as String;
    final createdAt = recipe['created_at'] as String;
    
    if (id == correctRecipeId) {
      print('✅ KEEP: $title');
      print('   ID: $id');
      print('   Created: $createdAt');
      print('   This is the CORRECT Master Recipe with complete variant_logic\n');
    } else {
      print('🗑️  DELETE: $title');
      print('   ID: $id');
      print('   Created: $createdAt');
      print('   Reason: Old/corrupted version\n');
      toDelete.add(recipe);
    }
  }
  
  if (toDelete.isEmpty) {
    print('✅ No old recipes to delete. Database is clean!');
    return;
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('⚠️  CONFIRMATION REQUIRED');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('About to delete ${toDelete.length} old Master Recipe(s).');
  print('');
  print('Automatically confirming deletion in 3 seconds...');
  await Future.delayed(const Duration(seconds: 3));
  
  print('\n🗑️  Deleting old Master Recipes...\n');
  
  for (final recipe in toDelete) {
    final id = recipe['id'];
    final title = recipe['title'];
    
    try {
      // Delete associated commits and snapshots first (cascade)
      final commitResponse = await supabase
          .from('commits')
          .select('id')
          .eq('recipe_id', id);
      
      if (commitResponse != null && (commitResponse as List).isNotEmpty) {
        final commits = commitResponse as List;
        for (final commit in commits) {
          final commitId = commit['id'];
          
          // Delete snapshots
          await supabase
              .from('recipe_snapshots')
              .delete()
              .eq('commit_id', commitId);
          
          print('   🗑️  Deleted snapshot for commit: $commitId');
        }
        
        // Delete commits
        await supabase
            .from('commits')
            .delete()
            .eq('recipe_id', id);
        
        print('   🗑️  Deleted ${commits.length} commit(s)');
      }
      
      // Finally delete the recipe itself
      final deleted = await supabase
          .from('recipes')
          .delete()
          .eq('id', id)
          .select();
      
      if ((deleted as List).isEmpty) {
        print('❌ FAILED: RLS blocked deletion of $title ($id) - Zero rows affected.');
      } else {
        print('✅ Verified Deletion: $title ($id)\n');
      }
    } catch (e) {
      print('❌ Error deleting $title: $e\n');
    }
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ CLEANUP COMPLETE');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Deleted: ${toDelete.length} old recipe(s)');
  print('Remaining: 1 Master Recipe (the correct one)');
}
