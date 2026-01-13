import 'dart:convert';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  // Hardcoded credentials (same as import script)
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  print('Authenticating anonymously for read access...');
  try {
    await supabase.auth.signInAnonymously();
  } catch (e) {
    print('Auth failed: $e');
    return;
  }

  final targetId = 'GOS-05';
  print('Fetching recipe with legacy ID: $targetId ...');

  try {
    // 1. Fetch Header
    final response = await supabase
        .from('recipes')
        .select()
        .ilike('title', '%[$targetId]%')
        .maybeSingle();

    if (response == null) {
      print('❌ Error: Recipe $targetId not found in recipes table.');
      return;
    }

    final id = response['id'];
    print('\n✅ RECIPE HEADER FOUND');
    print('------------------------------------------------');
    print('DB UUID:      ${response['id']}');
    print('Title:        ${response['title']}');
    print('Author ID:    ${response['author_id']}');
    print('Tags:         ${response['tags']}');
    print('Description:\n${response['description']}');
    print('------------------------------------------------');

    // 2. Fetch Latest Snapshot (to check steps)
    final snapshotResponse = await supabase
        .from('recipe_snapshots')
        .select()
        .eq('recipe_id', id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (snapshotResponse == null) {
      print('❌ Error: No snapshot found for recipe $id');
      return;
    }

    final fullStructure = snapshotResponse['full_structure'];
    final steps = fullStructure['steps'] as List;

    print('\n✅ SNAPSHOT DATA (Steps & Logic)');
    print('------------------------------------------------');
    print('Total Steps: ${steps.length}');
    
    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];
      // Handle both Map and potential String legacy (though V3 is strictly Map)
      if (s is Map) {
        print('\nStep ${i + 1}: "${s['instruction'].toString().substring(0, 50)}..."');
        if (s['is_branch_point'] == true) {
           print('   ↳ 🌿 BRANCH POINT DETECTED');
           final variants = s['variant_logic'] as Map;
           print('   ↳ Variants: ${variants.keys.join(', ')}');
        } else {
           print('   ↳ (Linear Step)');
        }
      } else {
        print('\nStep ${i + 1}: $s');
      }
    }
    print('------------------------------------------------');

    // 3. Validation Logic
    bool tagsValid = (response['tags'] as List).contains('Keto') && (response['tags'] as List).contains('Renal');
    bool descValid = response['description'].toString().contains('Additional Info:') && response['description'].toString().contains('Prep Time:');
    bool variantsValid = steps.any((s) => s['variant_logic'] != null && (s['variant_logic'] as Map).isNotEmpty);

    print('\n🕵️ VERIFICATION SUMMARY');
    print('   - Title Preservation:    ${response['title'].toString().startsWith('[$targetId]') ? 'OK' : 'FAIL'}');
    print('   - Metadata Injection:    ${descValid ? 'OK (Prep/Cook stats found)' : 'FAIL'}');
    print('   - Tag Calculation:       ${tagsValid ? 'OK (Found Keto/Renal)' : 'FAIL'}');
    print('   - Snapshot Logic:        ${variantsValid ? 'OK (Variants preserved)' : 'FAIL'}');

  } catch (e) {
     print('Exception during verification: $e');
  }
}
