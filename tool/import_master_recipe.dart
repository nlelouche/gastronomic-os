import 'dart:io';
import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

// Standalone Diet Logic for seeding
class SeederDietEngine {
  static List<String> calculateTags(Map<String, dynamic> recipe) {
    final Set<String> tags = {};
    if (recipe['tags'] != null) {
      for (var t in recipe['tags']) {
        tags.add(t.toString());
      }
    }
    return tags.toList();
  }
}

Future<void> main() async {
  // Hardcoded for local script usage
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  const uuid = Uuid();

  // 1b. Authenticate (Anonymous) to bypass RLS
  print('Authenticating anonymously...');
  String authorId;
  try {
    final response = await supabase.auth.signInAnonymously();
    if (response.user != null) {
      authorId = response.user!.id;
      print('  - Signed in as anonymous user: $authorId');
    } else {
       throw 'Anonymous login failed';
    }
  } catch (e) {
      print('CRITICAL: Auth failed. $e');
      return;
  }

  // 2. Locate File
  final masterFile = File(r'd:\Gastronomic OS\Documentation\test_recipes\json\master_recipe.json');
  if (!masterFile.existsSync()) {
    print('Master recipe file not found!');
    return;
  }
  
  print('Reading master recipe...');
  final content = await masterFile.readAsString();
  final List<dynamic> parsed = jsonDecode(content);
  
  print('Found ${parsed.length} recipes in file.');

  // 3. Import
  for (var r in parsed) {
    try {
      final oldId = r['id'].toString();
      // Check if exists to update or create new? 
      // We will create a new one for this test run or try to find by title?
      // Let's ALWAYS create a new one to avoid conflicts, or use a specific ID if we want to replace.
      // For stress test, let's create a NEW one.
      final newId = uuid.v4(); 

      // Calculate Tags
      final dietTags = SeederDietEngine.calculateTags(r);
      
      // 1. Insert Header (recipes)
      final recipePayload = {
        'id': newId, 
        'title': '[MASTER] ${r['title']}',
        'description': r['description'],
        'tags': dietTags, 
        'author_id': authorId, 
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await supabase.from('recipes').upsert(recipePayload);

      // 2. Insert Commit
      final commitPayload = {
        'recipe_id': newId,
        'author_id': authorId,
        'message': 'Master Recipe Import',
        'diff': {'action': 'import'},
      };
      
      final commitResponse = await supabase
        .from('commits')
        .insert(commitPayload)
        .select()
        .single();
        
      final commitId = commitResponse['id'];

      // 3. Insert Snapshot
      final fullStructure = {
        'ingredients': r['ingredients'] ?? [],
        'steps': r['steps'] ?? [], 
      };

      final snapshotPayload = {
        'commit_id': commitId,
        'recipe_id': newId,
        'full_structure': fullStructure,
      };

      await supabase.from('recipe_snapshots').insert(snapshotPayload);

      print('  - Inserted MASTER RECIPE: $newId');
    } catch (e) {
      print('Error inserting ${r['id']}: $e');
    }
  }

  print('DONE.');
}
