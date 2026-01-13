import 'dart:io';
import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart';

// Standalone Diet Logic for seeding
class SeederDietEngine {
  static List<String> calculateTags(Map<String, dynamic> recipe) {
    // ... (logic remains same)
    final Set<String> tags = {};
    final steps = (recipe['steps'] as List?) ?? [];
    
    // 1. Check Variants in attributes
    if (recipe['tags'] != null) {
      for (var t in recipe['tags']) {
        tags.add(t.toString());
      }
    }

    // 2. Check Steps for Variant Logic
    for (var step in steps) {
      if (step is Map && step.containsKey('variant_logic')) {
        final variants = step['variant_logic'] as Map<String, dynamic>;
        for (var key in variants.keys) {
          if (key.toLowerCase().contains('keto')) tags.add('Keto');
          if (key.toLowerCase().contains('renal')) tags.add('Renal');
          if (key.toLowerCase().contains('diabetes')) tags.add('Diabetes');
          if (key.toLowerCase().contains('vegan')) tags.add('Vegan');
          if (key.toLowerCase().contains('fodmap')) tags.add('Low FODMAP');
          if (key.toLowerCase().contains('gluten') || key.toLowerCase().contains('celiac')) tags.add('Celiac');
          if (key.toLowerCase().contains('histamine')) tags.add('Histamine');
          if (key.toLowerCase().contains('paleo')) tags.add('Paleo');
          if (key.toLowerCase().contains('whole30')) tags.add('Whole30');
          if (key.toLowerCase().contains('aplv') || key.toLowerCase().contains('dairy')) tags.add('APLV');
        }
      }
    }

    // 3. Inference based on Title/Description
    final title = recipe['title'].toString().toLowerCase();
    if (title.contains('keto')) tags.add('Keto');
    if (title.contains('vegan')) tags.add('Vegan');
    
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

  // 2. Locate Files
  final recipesDir = Directory(r'd:\Gastronomic OS\Documentation\RecipesV3');
  final batchFiles = await recipesDir.list().where((e) => e.path.endsWith('.txt') && e.path.contains('Batch')).toList();
  
  print('Found ${batchFiles.length} batch files.');

  // 3. Process each file
  final List<Map<String, dynamic>> allRecipes = [];

  for (var entity in batchFiles) {
    if (entity is File) {
      print('Processing ${entity.path}...');
      final content = await entity.readAsString();
      
      // Extract JSON using regex (Find list brackets [])
      final jsonMatch = RegExp(r'\[\s*\{.*\}\s*\]', multiLine: true, dotAll: true).firstMatch(content);
      
      if (jsonMatch != null) {
        try {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> parsed = jsonDecode(jsonStr);
          print('  - Found ${parsed.length} recipes');
          
          for (var item in parsed) {
             if (item is Map<String, dynamic>) {
               allRecipes.add(item);
             }
          }
        } catch (e) {
          print('  - JSON Parse Error: $e');
        }
      } else {
        print('  - No JSON block found');
      }
    }
  }

  print('Total Recipes Extracted: ${allRecipes.length}');
  
  if (allRecipes.isEmpty) {
    print('Aborting: No recipes found.');
    return;
  }

  // 4. Seed Supabase
  print('Clearing existing recipes...');
  try {
     // Order matters for FK constraints
     await supabase.from('recipe_snapshots').delete().neq('commit_id', '00000000-0000-0000-0000-000000000000');
     await supabase.from('commits').delete().neq('id', '00000000-0000-0000-0000-000000000000');
     await supabase.from('recipes').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  } catch (e) {
    print('Warning deleting recipes (might be empty): $e');
  }

  print('Inserting new recipes...');
  int successCount = 0;
  
  // final systemUserId = '00000000-0000-0000-0000-000000000000'; // REPLACED

  for (var r in allRecipes) {
    try {
      final oldId = r['id'].toString();
      final newId = uuid.v4(); // Generate UUID for DB

      // Enhance Description
      String desc = r['description'] ?? '';
      final prep = r['prep_time'];
      final cook = r['cook_time'];
      final servings = r['servings'];
      
      if (prep != null || cook != null || servings != null) {
        desc += '\n\nAdditional Info:';
        if (prep != null) desc += '\nPrep Time: $prep';
        if (cook != null) desc += '\nCook Time: $cook';
        if (servings != null) desc += '\nServings: $servings';
      }

      // Calculate Tags
      final dietTags = SeederDietEngine.calculateTags(r);
      
      // 1. Insert Header (recipes)
      final recipePayload = {
        'id': newId, 
        'title': '[$oldId] ${r['title']}', // Preserve GOS-XX in title
        'description': desc,
        'tags': dietTags, // Save calculated tags here
        'author_id': authorId, // AUTHENTICATED USER 
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await supabase.from('recipes').upsert(recipePayload);

      // 2. Insert Commit
      final commitPayload = {
        'recipe_id': newId,
        'author_id': authorId, // AUTHENTICATED USER
        'message': 'Initial V3 Import ($oldId)',
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

      successCount++;
      print('  - Inserted $oldId -> $newId (${r['title']})');
    } catch (e) {
      print('Error inserting ${r['id']}: $e');
    }
  }

  print('DONE. Data seeding complete.');
  print('Successfully inserted: $successCount / ${allRecipes.length}');
}
