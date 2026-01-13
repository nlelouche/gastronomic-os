import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';
  
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    await supabase.auth.signInAnonymously();
    print('Auth: ${supabase.auth.currentUser?.id}');
    
    final recipeId = 'efb21b1b-0f68-44fe-8f08-f10e03ccfe71';
    
    // Check Snapshots
    print('Checking snapshots for: $recipeId');
    final snapshots = await supabase
        .from('recipe_snapshots')
        .select('id, created_at, commit_id')
        .eq('recipe_id', recipeId);
        
    print('Found ${(snapshots as List).length} snapshots.');
    for (var s in snapshots) {
      print(' - Snapshot: ${s['id']} (Commit: ${s['commit_id']})');
    }

  } catch (e) {
    print('Error: $e');
  }
}
