import 'dart:io';
import 'dart:convert';
import 'package:supabase/supabase.dart';

/// Diagnostic tool to verify Master Recipe in database
/// Checks if variant_logic for "Soy Allergy" is present
Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('🔍 Searching for Master Recipe...');
  
  // Find all recipes
  final recipesResponse = await supabase
      .from('recipes')
      .select('id, title')
      .ilike('title', '%MASTER%');
  
  if (recipesResponse == null || (recipesResponse as List).isEmpty) {
    print('❌ No Master Recipe found!');
    return;
  }
  
  final recipes = recipesResponse as List;
  print('✅ Found ${recipes.length} Master Recipe(s):');
  for (final recipe in recipes) {
    print('   - ${recipe['title']} (ID: ${recipe['id']})');
  }
  
  // Get the first one
  final masterRecipeId = recipes[0]['id'];
  print('\n📖 Loading Master Recipe: $masterRecipeId');
  
  // Get latest commit
  final commitResponse = await supabase
      .from('commits')
      .select('id')
      .eq('recipe_id', masterRecipeId)
      .order('created_at', ascending: false)
      .limit(1)
      .single();
  
  if (commitResponse == null) {
    print('❌ No commits found for Master Recipe!');
    return;
  }
  
  final commitId = commitResponse['id'];
  print('✅ Latest commit: $commitId');
  
  // Get snapshot
  final snapshotResponse = await supabase
      .from('recipe_snapshots')
      .select('full_structure')
      .eq('commit_id', commitId)
      .single();
  
  if (snapshotResponse == null) {
    print('❌ No snapshot found!');
    return;
  }
  
  final fullStructure = snapshotResponse['full_structure'];
  final steps = fullStructure['steps'] as List;
  
  print('\n🔍 Analyzing ${steps.length} steps...\n');
  
  bool foundSoyVariant = false;
  
  for (int i = 0; i < steps.length; i++) {
    final step = steps[i];
    final instruction = step['instruction'] as String;
    final variantLogic = step['variant_logic'];
    
    if (instruction.toLowerCase().contains('sazonar') || 
        instruction.toLowerCase().contains('salsa de soja')) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 STEP ${i + 1}: SAZONAR (Soy Sauce Step)');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Instruction: "$instruction"');
      print('is_branch_point: ${step['is_branch_point']}');
      print('');
      
      if (variantLogic != null && variantLogic is Map) {
        print('variant_logic keys: ${variantLogic.keys.toList()}');
        print('');
        
        // Check for Soy Allergy specifically
        if (variantLogic.containsKey('Soy Allergy')) {
          foundSoyVariant = true;
          print('✅ "Soy Allergy" variant FOUND:');
          print('   "${variantLogic['Soy Allergy']}"');
        } else {
          print('❌ "Soy Allergy" variant NOT FOUND');
          print('   Available variants:');
          variantLogic.forEach((key, value) {
            print('   - "$key" (${key.runtimeType}): "${value.toString().substring(0, 50)}..."');
          });
        }
      } else {
        print('❌ No variant_logic found or it is not a Map!');
        print('   Type: ${variantLogic.runtimeType}');
      }
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }
  
  if (!foundSoyVariant) {
    print('🚨 CRITICAL ISSUE: "Soy Allergy" variant NOT in database!');
    print('   The Master Recipe in Supabase is missing the variant.');
    print('   Need to re-import from JSON file.');
  } else {
    print('✅ "Soy Allergy" variant exists in database.');
    print('   Issue must be in app logic or enum keys.');
  }
}
